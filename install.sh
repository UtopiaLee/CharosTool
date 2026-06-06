#!/usr/bin/env bash
set -euo pipefail

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
./bin/request_ssl.sh "$DOMAIN"

# 3. Run Proxy API Install
echo "--- Installing/Configuring Proxy API ---"
./bin/install_proxy.sh "$DOMAIN"

# 4. Create Shortcut
echo "--- Setting up global shortcut 'charos' ---"
sudo ln -sf "$PWD/bin/menu.sh" /usr/local/bin/charos
sudo chmod +x /usr/local/bin/charos

echo "=== Installation Complete ==="
echo "You can now run 'charos' to manage your toolbox."
