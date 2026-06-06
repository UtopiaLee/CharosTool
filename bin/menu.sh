#!/usr/bin/env bash
# bin/menu.sh - Interactive menu for Linux Toolbox
set -euo pipefail

TOOLBOX_DIR="/opt/linux-toolbox"

while true; do
    echo "=================================="
    echo "   CharosTool Menu"
    echo "=================================="
    echo "1. Request SSL Certificate"
    echo "2. Install/Configure Proxy API"
    echo "3. Update Toolbox"
    echo "4. Health Check"
    echo "5. Exit"
    echo "=================================="
    read -p "Select an option [1-5]: " option
    echo ""
    case $option in
        1)
            read -p "Enter domain name: " domain
            sudo "$TOOLBOX_DIR/bin/request_ssl.sh" "$domain"
            ;;
        2)
            read -p "Enter domain name: " domain
            sudo "$TOOLBOX_DIR/bin/install_proxy.sh" "$domain"
            ;;
        3)
            "$TOOLBOX_DIR/bin/update_toolbox.sh"
            ;;
        4)
            "$TOOLBOX_DIR/bin/health_check.sh"
            ;;
        5)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    echo ""
    read -p "Press Enter to continue..."
done
