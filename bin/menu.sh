#!/usr/bin/env bash
# bin/menu.sh - Interactive menu for Linux Toolbox
set -euo pipefail

TOOLBOX_DIR="/opt/linux-toolbox"

while true; do
    echo "=================================="
    echo "      CharosTool 工具菜单"
    echo "=================================="
    echo "1. 安装/更新并启动 CLIProxyAPI"
    echo "2. 启动 CLIProxyAPI 服务"
    echo "3. 停止 CLIProxyAPI 服务"
    echo "4. 重启 CLIProxyAPI 服务"
    echo "5. 查看 CLIProxyAPI 状态"
    echo "6. 修改管理密码"
    echo "7. 更新工具箱"
    echo "8. 健康检查"
    echo "9. 退出"
    echo "=================================="
    read -p "请选择一个选项 [1-9]: " option
    echo ""
    case $option in
        1)
            read -p "请输入域名: " domain
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" "$domain"
            ;;
        2)
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" start
            ;;
        3)
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" stop
            ;;
        4)
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" restart
            ;;
        5)
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" status
            ;;
        6)
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" password
            ;;
        7)
            "$TOOLBOX_DIR/bin/update_toolbox.sh"
            ;;
        8)
            "$TOOLBOX_DIR/bin/health_check.sh"
            ;;
        9)
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
