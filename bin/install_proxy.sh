#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

TOOLBOX_DIR="/opt/linux-toolbox"
CLIPROXY_DIR="${TOOLBOX_DIR}/cliproxyapi"
SERVICE_NAME="cliproxyapi.service"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}"
REPO_OWNER="router-for-me"
REPO_NAME="CLIProxyAPI"
API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"

cleanup() {
    if [[ -n "${TMP_DIR:-}" && -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

ensure_dependencies() {
    local missing=()

    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing+=("curl or wget")
    fi

    if ! command -v tar >/dev/null 2>&1; then
        missing+=("tar")
    fi

    if ! command -v python3 >/dev/null 2>&1; then
        log_info "Installing python3..."
        sudo apt-get update && sudo apt-get install -y python3
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        exit 1
    fi
}

detect_linux_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            echo "linux_amd64"
            ;;
        arm64|aarch64)
            echo "linux_aarch64"
            ;;
        *)
            log_error "Unsupported architecture: $(uname -m). Only x86_64 and aarch64 are supported."
            exit 1
            ;;
    esac
}

fetch_release_info() {
    log_info "Fetching latest CLIProxyAPI release..."

    local release_info
    if command -v curl >/dev/null 2>&1; then
        release_info=$(curl -fsSL "$API_URL")
    else
        release_info=$(wget -qO- "$API_URL")
    fi

    if [[ -z "$release_info" ]]; then
        log_error "Failed to fetch release information from GitHub"
        exit 1
    fi

    echo "$release_info"
}

extract_release_info() {
    local release_info="$1"
    local os_arch="$2"

    local version
    version=$(echo "$release_info" | grep -o '"tag_name": *"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')
    if [[ -z "$version" ]]; then
        log_error "Failed to parse release version"
        exit 1
    fi

    local expected_filename="CLIProxyAPI_${version}_${os_arch}.tar.gz"
    local download_url
    download_url=$(echo "$release_info" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep "/${expected_filename}$" | head -1)
    if [[ -z "$download_url" ]]; then
        log_error "Failed to find download URL for ${expected_filename}"
        exit 1
    fi

    echo "${version}|${download_url}"
}

download_file() {
    local url="$1"
    local output="$2"

    log_info "Downloading $(basename "$url")..."
    if command -v curl >/dev/null 2>&1; then
        curl -fL -o "$output" "$url"
    else
        wget -O "$output" "$url"
    fi

    if [[ ! -s "$output" ]]; then
        log_error "Download failed"
        exit 1
    fi
}

extract_archive() {
    local archive="$1"
    local dest_dir="$2"

    mkdir -p "$dest_dir"
    tar -xzf "$archive" -C "$dest_dir"
}

generate_api_key() {
    local prefix="sk-"
    local chars="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local key=""

    for _ in {1..45}; do
        key="${key}${chars:$((RANDOM % ${#chars})):1}"
    done

    echo "${prefix}${key}"
}

generate_secret_key() {
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 24
    echo
}

ensure_certificate() {
    local domain="$1"
    local cert_dir="/usr/tls/${domain}"
    local fullchain_file="${cert_dir}/fullchain.cer"
    local key_file="${cert_dir}/${domain}.key"

    if [[ -f "$fullchain_file" && -f "$key_file" ]]; then
        log_success "检测到现有证书：${fullchain_file}"
        return 0
    fi

    log_info "正在申请 SSL 证书..."
    "${TOOLBOX_DIR}/bin/request_ssl.sh" "$domain"
}

create_systemd_service() {
    local install_dir="$1"

    log_info "创建 systemd 服务..."
    cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=CLIProxyAPI Service
After=network.target

[Service]
Type=simple
WorkingDirectory=${install_dir}
ExecStart=${install_dir}/cli-proxy-api
Restart=always
RestartSec=10
Environment=HOME=/root

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME" >/dev/null
}

start_service() {
    log_info "启动 CLIProxyAPI 服务..."
    systemctl start "$SERVICE_NAME"
    sleep 2
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "CLIProxyAPI 服务已启动"
    else
        log_warning "服务可能未正常启动，请检查：systemctl status ${SERVICE_NAME}"
    fi
}

stop_service() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_info "停止 CLIProxyAPI 服务..."
        systemctl stop "$SERVICE_NAME"
        log_success "CLIProxyAPI 服务已停止"
    else
        log_info "CLIProxyAPI 服务当前未运行"
    fi
}

restart_service() {
    log_info "重启 CLIProxyAPI 服务..."
    systemctl restart "$SERVICE_NAME"
    sleep 2
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        log_success "CLIProxyAPI 服务已重启"
    else
        log_warning "服务可能未正常重启，请检查：systemctl status ${SERVICE_NAME}"
    fi
}

show_status() {
    echo "CLIProxyAPI 状态"
    echo "=============================="
    echo "安装目录: ${CLIPROXY_DIR}"
    if [[ -f "${CLIPROXY_DIR}/version.txt" ]]; then
        echo "版本: $(cat "${CLIPROXY_DIR}/version.txt")"
    else
        echo "版本: 未安装"
    fi
    if [[ -f "${CLIPROXY_DIR}/config.yaml" ]]; then
        echo "配置文件: ${CLIPROXY_DIR}/config.yaml"
    else
        echo "配置文件: 缺失"
    fi
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "服务状态: 运行中"
    else
        echo "服务状态: 未运行"
    fi
    if [[ -f "$SERVICE_FILE" ]]; then
        echo "服务文件: $SERVICE_FILE"
    else
        echo "服务文件: 缺失"
    fi
}

get_current_allow_remote() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        echo "false"
        return 0
    fi

    local value
    value=$(grep -E '^  allow-remote:' "$config_file" | head -1 | awk -F': ' '{print $2}' | tr -d '[:space:]')
    if [[ "$value" == "true" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

update_config_file() {
    local config_file="$1"
    local domain="$2"
    local secret_key="${3:-}"
    local allow_remote="${4:-}"
    local api_keys_blob="${5:-}"

    python3 - "$config_file" "$domain" "$secret_key" "$allow_remote" "$api_keys_blob" <<'PY'
import sys
import pathlib
import re

config_path = pathlib.Path(sys.argv[1])
domain = sys.argv[2]
secret_key = sys.argv[3]
allow_remote = sys.argv[4]
api_keys_blob = sys.argv[5]
api_keys = api_keys_blob.split('|') if api_keys_blob else []
cert_path = f"/usr/tls/{domain}/fullchain.cer"
key_path = f"/usr/tls/{domain}/{domain}.key"

text = config_path.read_text()
lines = text.splitlines(True)
out = []
section = None
api_index = 0

for line in lines:
    stripped = line.strip()

    if stripped == 'tls:':
        section = 'tls'
        out.append(line)
        continue
    if stripped == 'remote-management:':
        section = 'remote'
        out.append(line)
        continue
    if stripped == 'api-keys:':
        section = 'api'
        out.append(line)
        continue

    if re.match(r'^[A-Za-z0-9_-]+:\s*$', stripped) and not line.startswith(' '):
        section = None

    if not line.startswith(' ') and stripped.startswith('host:'):
        out.append('host: ""\n')
        continue
    if not line.startswith(' ') and stripped.startswith('port:'):
        out.append('port: 8317\n')
        continue
    if not line.startswith(' ') and stripped.startswith('auth-dir:'):
        out.append('auth-dir: "~/.cli-proxy-api"\n')
        continue

    if section == 'tls' and line.startswith('  '):
        if stripped.startswith('enable:'):
            out.append('  enable: true\n')
            continue
        if stripped.startswith('cert:'):
            out.append(f'  cert: "{cert_path}"\n')
            continue
        if stripped.startswith('key:'):
            out.append(f'  key: "{key_path}"\n')
            continue

    if section == 'remote' and line.startswith('  '):
        if stripped.startswith('allow-remote:') and allow_remote:
            out.append(f'  allow-remote: {allow_remote}\n')
            continue
        if stripped.startswith('secret-key:') and secret_key:
            out.append(f'  secret-key: "{secret_key}"\n')
            continue

    if section == 'api' and line.startswith('  ') and api_index < len(api_keys):
        if 'your-api-key-' in stripped:
            out.append(f'  - "{api_keys[api_index]}"\n')
            api_index += 1
            continue

    out.append(line)

config_path.write_text(''.join(out))
PY
}

initialize_api_keys_if_needed() {
    local config_file="$1"
    if grep -q 'your-api-key-1' "$config_file" || grep -q 'your-api-key-2' "$config_file" || grep -q 'your-api-key-3' "$config_file"; then
        local key1 key2 key3
        key1=$(generate_api_key)
        key2=$(generate_api_key)
        key3=$(generate_api_key)
        python3 - "$config_file" "$key1" "$key2" "$key3" <<'PY'
import sys
import pathlib

config_path = pathlib.Path(sys.argv[1])
keys = sys.argv[2:5]
text = config_path.read_text()
text = text.replace('"your-api-key-1"', f'"{keys[0]}"', 1)
text = text.replace('"your-api-key-2"', f'"{keys[1]}"', 1)
text = text.replace('"your-api-key-3"', f'"{keys[2]}"', 1)
config_path.write_text(text)
PY
        log_success "已生成 CLIProxyAPI API Keys"
        log_info "API Key 1: $key1"
        log_info "API Key 2: $key2"
        log_info "API Key 3: $key3"
    fi
}

set_management_password() {
    local config_file="$1"
    local secret_key="$2"
    local allow_remote="$3"

    update_config_file "$config_file" "$(get_config_domain_from_tls "$config_file")" "$secret_key" "$allow_remote" ""
}

get_config_domain_from_tls() {
    local config_file="$1"
    if [[ ! -f "$config_file" ]]; then
        return 0
    fi

    local cert_path
    cert_path=$(grep -E '^  cert:' "$config_file" | head -1 | awk -F': ' '{print $2}' | tr -d '"')
    if [[ -n "$cert_path" ]]; then
        basename "$(dirname "$cert_path")"
    fi
}

prompt_secret_key() {
    local prompt="${1:-请输入 CLIProxyAPI 管理密码（留空自动生成）: }"
    local secret_key
    read -r -p "$prompt" secret_key
    if [[ -z "$secret_key" ]]; then
        secret_key=$(generate_secret_key)
        echo "$secret_key"
        return 0
    fi
    echo "$secret_key"
}

prompt_allow_remote() {
    local answer
    read -r -p "是否允许远程访问管理面板？[y/N]: " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "true"
    else
        echo "false"
    fi
}

install_or_update_cliproxyapi() {
    local domain="$1"
    local config_file="${CLIPROXY_DIR}/config.yaml"

    ensure_dependencies
    ensure_certificate "$domain"

    local os_arch
    os_arch=$(detect_linux_arch)

    local release_info
    release_info=$(fetch_release_info)
    local release_data version download_url
    release_data=$(extract_release_info "$release_info" "$os_arch")
    version=$(echo "$release_data" | cut -d'|' -f1)
    download_url=$(echo "$release_data" | cut -d'|' -f2)

    mkdir -p "$CLIPROXY_DIR"
    TMP_DIR=$(mktemp -d)
    local archive="$TMP_DIR/cliproxyapi.tar.gz"
    local extract_dir="$TMP_DIR/extract"

    download_file "$download_url" "$archive"
    extract_archive "$archive" "$extract_dir"

    local binary example_config
    binary=$(find "$extract_dir" -type f \( -name 'cli-proxy-api' -o -name 'CLIProxyAPI' \) | head -1)
    example_config=$(find "$extract_dir" -type f -name 'config.example.yaml' | head -1)

    if [[ -z "$binary" ]]; then
        log_error "未找到 CLIProxyAPI 可执行文件"
        exit 1
    fi

    cp "$binary" "${CLIPROXY_DIR}/cli-proxy-api"
    chmod +x "${CLIPROXY_DIR}/cli-proxy-api"
    echo "$version" > "${CLIPROXY_DIR}/version.txt"

    local fresh_install=false
    if [[ ! -f "$config_file" ]]; then
        fresh_install=true
        if [[ -n "$example_config" ]]; then
            cp "$example_config" "$config_file"
        else
            log_error "未找到 config.example.yaml"
            exit 1
        fi
    fi

    local secret_key allow_remote api_keys_blob=""
    if [[ "$fresh_install" == true ]]; then
        secret_key=$(prompt_secret_key)
        allow_remote=$(prompt_allow_remote)
        api_keys_blob="$(generate_api_key)|$(generate_api_key)|$(generate_api_key)"
        initialize_api_keys_if_needed "$config_file"
    else
        secret_key=""
        allow_remote=""
    fi

    update_config_file "$config_file" "$domain" "$secret_key" "$allow_remote" "$api_keys_blob"
    create_systemd_service "$CLIPROXY_DIR"
    start_service

    log_success "CLIProxyAPI ${version} 安装/更新完成"
    echo
    echo "安装目录: ${CLIPROXY_DIR}"
    echo "配置文件: ${config_file}"
    echo "服务名称: ${SERVICE_NAME}"
    echo "管理地址: https://<你的域名>:8317"
    echo "管理密码: $(grep -E '^  secret-key:' "$config_file" | head -1 | awk -F': ' '{print $2}' | tr -d '"')"
}

change_management_password() {
    local config_file="${CLIPROXY_DIR}/config.yaml"

    if [[ ! -f "$config_file" ]]; then
        log_error "未找到配置文件，请先安装 CLIProxyAPI"
        exit 1
    fi

    local secret_key allow_remote
    secret_key=$(prompt_secret_key "请输入新的管理密码（留空自动生成）: ")
    allow_remote=$(prompt_allow_remote)

    update_config_file "$config_file" "$(get_config_domain_from_tls "$config_file")" "$secret_key" "$allow_remote" ""
    restart_service

    log_success "管理密码已更新"
    echo "新的管理密码: $secret_key"
}

main() {
    local cmd="${1:-setup}"

    case "$cmd" in
        setup|install|upgrade)
            local domain="${2:-}"
            if [[ -z "$domain" && "$cmd" != "upgrade" ]]; then
                read -r -p "请输入域名: " domain
            fi
            if [[ -z "$domain" ]]; then
                log_error "域名不能为空"
                exit 1
            fi
            install_or_update_cliproxyapi "$domain"
            ;;
        start)
            start_service
            ;;
        stop)
            stop_service
            ;;
        restart)
            restart_service
            ;;
        status)
            show_status
            ;;
        password|change-password)
            change_management_password
            ;;
        help|--help|-h)
            cat <<EOF
CLIProxyAPI 管理脚本

用法:
  $0 setup <domain>        安装/更新并启动
  $0 start                 启动服务
  $0 stop                  停止服务
  $0 restart               重启服务
  $0 status                查看状态
  $0 password              修改管理密码
EOF
            ;;
        *)
            if [[ $# -eq 1 ]]; then
                install_or_update_cliproxyapi "$1"
            else
                log_error "未知命令: $cmd"
                exit 1
            fi
            ;;
    esac
}

main "$@"
