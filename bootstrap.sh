#!/usr/bin/env bash
# bootstrap.sh - Install and execute Linux Toolbox
set -euo pipefail

echo "Checking prerequisites..."
if ! command -v git &> /dev/null || ! command -v wget &> /dev/null; then
    echo "Installing prerequisites (git, wget)..."
    sudo apt-get update && sudo apt-get install -y git wget
fi

if ! command -v acme.sh &> /dev/null && [ ! -x "/root/.acme.sh/acme.sh" ]; then
    echo "Installing acme.sh..."
    curl -fsSL https://get.acme.sh | sh -s email=root@localhost
fi

INSTALL_DIR="/opt/linux-toolbox"
REPO_URL="https://github.com/UtopiaLee/CharosTool.git"

echo "Installing Linux Toolbox to $INSTALL_DIR..."

# Ensure we're in a safe directory before any operations
cd /tmp

if [ -d "$INSTALL_DIR" ]; then
    echo "Removing old installation..."
    sudo rm -rf "$INSTALL_DIR"
fi

echo "Cloning repository..."
sudo git clone "$REPO_URL" "$INSTALL_DIR"

echo "Starting installer..."
sudo chmod +x "$INSTALL_DIR/install.sh"
sudo chmod +x "$INSTALL_DIR/bin"/*.sh
sudo "$INSTALL_DIR/install.sh"
