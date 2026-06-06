#!/usr/bin/env bash
# Script to update the Linux Toolbox from GitHub
set -euo pipefail

# Define the repository path
REPO_PATH="/opt/linux-toolbox"

if [ ! -d "$REPO_PATH" ]; then
    echo "Directory $REPO_PATH does not exist. Please clone the repository first:"
    echo "sudo git clone <your-repo-url> $REPO_PATH"
    exit 1
fi

echo "Updating Linux Toolbox..."
cd "$REPO_PATH"
git pull origin main
echo "Toolbox updated successfully."
