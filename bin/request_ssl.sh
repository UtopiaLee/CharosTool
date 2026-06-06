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
    curl -fsSL https://get.acme.sh | sh -s email=root@example.com
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

# Ensure account email is valid so registration won't fail on a stale localhost address.
sudo "$ACME_BIN" --update-account -m root@example.com >/dev/null 2>&1 || true

# Force Let's Encrypt to avoid ZeroSSL EAB requirements.
# Issue the certificate first, then install the files separately.
if sudo "$ACME_BIN" --server letsencrypt --issue --standalone -d "$DOMAIN"; then
    if sudo "$ACME_BIN" --server letsencrypt --install-cert -d "$DOMAIN" \
        --cert-file "$CERT_PATH/$DOMAIN.cer" \
        --key-file "$CERT_PATH/$DOMAIN.key" \
        --fullchain-file "$CERT_PATH/fullchain.cer"; then
        log_info "Successfully obtained and installed certificate for $DOMAIN in $CERT_PATH."
    else
        log_error "Issued certificate for $DOMAIN, but failed to install it to $CERT_PATH."
        exit 1
    fi
else
    log_error "Failed to obtain certificate for $DOMAIN."
    exit 1
fi
