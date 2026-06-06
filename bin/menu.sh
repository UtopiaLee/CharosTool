#!/usr/bin/env bash
# bin/menu.sh - Interactive menu for Linux Toolbox
set -euo pipefail

TOOLBOX_DIR="/opt/linux-toolbox"

show_menu() {
    echo "=================================="
    echo "   CharosTool Menu"
    echo "=================================="
    echo "1. Request SSL Certificate"
    echo "2. Install/Configure Proxy API"
    echo "3. Update Toolbox"
    echo "4. Exit"
    echo "=================================="
}

while true; do
    show_menu
    read -p "Select an option [1-4]: " option
    case $option in
        1) sudo "$TOOLBOX_DIR/bin/request_ssl.sh" ;;
        2) sudo "$TOOLBOX_DIR/bin/install_proxy.sh" ;;
        3) "$TOOLBOX_DIR/bin/update_toolbox.sh" ;;
        4) exit 0 ;;
        *) echo "Invalid option." ;;
    esac
    echo ""
done
