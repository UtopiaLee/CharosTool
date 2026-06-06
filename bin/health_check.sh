#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

log_info "Starting system health check..."

# Example: Check disk space
df -h | head -n 5

log_info "Health check complete."
