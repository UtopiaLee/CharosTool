#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

ACME_BIN="$(command -v acme.sh || true)"
if [ -z "$ACME_BIN" ] && [ -x "/root/.acme.sh/acme.sh" ]; then
    ACME_BIN="/root/.acme.sh/acme.sh"
fi

if [ -z "$ACME_BIN" ]; then
    log_info "acme.sh is not installed. Installing acme.sh..."
    curl -fsSL https://get.acme.sh | sh -s email=root@localhost
    ACME_BIN="/root/.acme.sh/acme.sh"
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
if sudo "$ACME_BIN" --issue --standalone -d "$DOMAIN" --install-cert -d "$DOMAIN" \
    --cert-file "$CERT_PATH/$DOMAIN.cer" \
    --key-file "$CERT_PATH/$DOMAIN.key" \
    --fullchain-file "$CERT_PATH/fullchain.cer"; then
    log_info "Successfully obtained and installed certificate for $DOMAIN in $CERT_PATH."
else
    log_error "Failed to obtain or install certificate for $DOMAIN."
    exit 1
fi
