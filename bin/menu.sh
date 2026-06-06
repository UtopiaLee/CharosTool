#!/usr/bin/env bash
# bin/menu.sh - Interactive menu for Linux Toolbox
set -euo pipefail

TOOLBOX_DIR="/opt/linux-toolbox"

while true; do
    echo "=================================="
    echo "      CharosTool 工具菜单"
    echo "=================================="
    echo "1. 申请 SSL 证书"
    echo "2. 安装/配置 Proxy API"
    echo "3. 更新工具箱"
    echo "4. 健康检查"
    echo "5. 退出"
    echo "=================================="
    read -p "请选择一个选项 [1-5]: " option
    echo ""
    case $option in
        1)
            read -p "请输入域名: " domain
            sudo "$TOOLBOX_DIR/bin/request_ssl.sh" "$domain"
            ;;
        2)
            read -p "请输入域名: " domain
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" "$domain"
            ;;
        3)
            "$TOOLBOX_DIR/bin/update_toolbox.sh"
            ;;
        4)
            "$TOOLBOX_DIR/bin/health_check.sh"
            ;;
        5)
            echo "正在退出..."
            exit 0
            ;;
        *)
            echo "无效选项，请重新选择。"
            ;;
    esac
    echo ""
    read -p "按 Enter 键继续..."
done
