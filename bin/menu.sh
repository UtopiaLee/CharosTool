#!/usr/bin/env bash
# bin/menu.sh - Interactive menu for Linux Toolbox
set -euo pipefail

TOOLBOX_DIR="/opt/linux-toolbox"

show_main_menu() {
    echo "=================================="
    echo "      CharosTool 工具菜单"
    echo "=================================="
    echo "1. CLIProxyAPI 子菜单"
    echo "2. 证书管理子菜单"
    echo "3. 更新工具箱"
    echo "4. 健康检查"
    echo "5. 退出"
    echo "=================================="
}

show_cliproxy_menu() {
    echo "=================================="
    echo "     CLIProxyAPI 子菜单"
    echo "=================================="
    echo "1. 安装/更新并启动"
    echo "2. 启动服务"
    echo "3. 停止服务"
    echo "4. 重启服务"
    echo "5. 查看状态"
    echo "6. 查看访问地址"
    echo "7. 修改管理密码"
    echo "8. 返回主菜单"
    echo "=================================="
}

show_certificate_menu() {
    echo "=================================="
    echo "        证书管理子菜单"
    echo "=================================="
    echo "1. 申请/更新 SSL 证书"
    echo "2. 返回主菜单"
    echo "=================================="
}

while true; do
    show_main_menu
    read -p "请选择一个选项 [1-5]: " option
    echo ""
    case $option in
        1)
            while true; do
                show_cliproxy_menu
                read -p "请选择一个选项 [1-8]: " coption
                echo ""
                case $coption in
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
                        sudo "$TOOLBOX_DIR/bin/install_proxy.sh" info
                        ;;
                    7)
                        sudo "$TOOLBOX_DIR/bin/install_proxy.sh" password
                        ;;
                    8)
                        break
                        ;;
                    *)
                        echo "无效选项，请重新选择。"
                        ;;
                esac
                echo ""
                read -p "按 Enter 键继续..."
            done
            ;;
        2)
            while true; do
                show_certificate_menu
                read -p "请选择一个选项 [1-2]: " cert_option
                echo ""
                case $cert_option in
                    1)
                        read -p "请输入域名: " domain
                        sudo "$TOOLBOX_DIR/bin/request_ssl.sh" "$domain"
                        ;;
                    2)
                        break
                        ;;
                    *)
                        echo "无效选项，请重新选择。"
                        ;;
                esac
                echo ""
                read -p "按 Enter 键继续..."
            done
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
