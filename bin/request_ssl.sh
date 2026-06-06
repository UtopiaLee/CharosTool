#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

# Check if acme.sh is installed
if ! command -v acme.sh &> /dev/null; then
    log_error "acme.sh is not installed. Please install acme.sh first."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    read -p "Enter domain name: " DOMAIN
else
    DOMAIN=$1
fi

if [ -z "$DOMAIN" ]; then
    log_error "Domain name is required."
    exit 1
fi
CERT_PATH="/usr/tls/$DOMAIN"

log_info "Attempting to request SSL certificate for $DOMAIN using acme.sh..."

# Create storage directory
sudo mkdir -p "$CERT_PATH"

# Use acme.sh to issue the certificate
# --standalone is used as an example, adjust according to your environment (e.g. --nginx, --apache)
if sudo acme.sh --issue --standalone -d "$DOMAIN" --install-cert -d "$DOMAIN" \
    --cert-file "$CERT_PATH/$DOMAIN.cer" \
    --key-file "$CERT_PATH/$DOMAIN.key" \
    --fullchain-file "$CERT_PATH/fullchain.cer"; then
    log_info "Successfully obtained and installed certificate for $DOMAIN in $CERT_PATH."
else
    log_error "Failed to obtain or install certificate for $DOMAIN."
    exit 1
fi
