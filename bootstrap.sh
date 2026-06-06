#!/usr/bin/env bash
# bootstrap.sh - Install and execute Linux Toolbox
set -euo pipefail

echo "Checking prerequisites..."
if ! command -v git &> /dev/null || ! command -v wget &> /dev/null; then
    echo "Installing prerequisites (git, wget)..."
    sudo apt-get update && sudo apt-get install -y git wget
fi

INSTALL_DIR="/opt/linux-toolbox"

echo "Installing Linux Toolbox to $INSTALL_DIR..."

if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin master
else
    echo "Cloning repository..."
    sudo git clone https://github.com/UtopiaLee/CharosTool.git "$INSTALL_DIR"
fi

echo "Starting installer..."
cd "$INSTALL_DIR"
sudo ./install.sh
