#!/usr/bin/env bash
set -euo pipefail

# Get the directory where this script resides (absolute path)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Main entry point for Linux Toolbox
echo "=== Welcome to Linux Toolbox Installer ==="

# 1. Prompt for Domain
read -p "Enter your domain name: " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo "Domain name is required. Exiting."
    exit 1
fi

# 2. Run SSL Request
echo "--- Requesting SSL Certificate ---"
"$SCRIPT_DIR/bin/request_ssl.sh" "$DOMAIN"

# 3. Run Proxy API Install
echo "--- Installing/Configuring Proxy API ---"
"$SCRIPT_DIR/bin/install_proxy.sh" "$DOMAIN"

# 4. Create Shortcut
echo "--- Setting up global shortcut 'charos' ---"
sudo ln -sf "$SCRIPT_DIR/bin/menu.sh" /usr/local/bin/charos
sudo chmod +x /usr/local/bin/charos

echo "=== Installation Complete ==="
echo "You can now run 'charos' to manage your toolbox."
