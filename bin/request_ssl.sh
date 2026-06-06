#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    log_error "Certbot is not installed. Please install certbot first."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    log_error "Usage: $0 <domain_name>"
    exit 1
fi

DOMAIN=$1

log_info "Attempting to request SSL certificate for $DOMAIN..."

# Use certbot to request a certificate (using standalone mode for simplicity, 
# in production this might require webserver integration)
if sudo certbot certonly --standalone -d "$DOMAIN"; then
    log_info "Successfully obtained certificate for $DOMAIN."
else
    log_error "Failed to obtain certificate for $DOMAIN."
    exit 1
fi
