#!/usr/bin/env bash
set -euo pipefail

# Source common library
source "$(dirname "$0")/../lib/common.sh"

if [ "$#" -ne 1 ]; then
    read -p "Enter domain name: " DOMAIN
else
    DOMAIN=$1
fi

if [ -z "$DOMAIN" ]; then
    log_error "Domain name is required."
    exit 1
fi

ACME_EMAIL="admin@$DOMAIN"
ACME_BIN="$(command -v acme.sh || true)"
if [ -z "$ACME_BIN" ] && [ -x "/root/.acme.sh/acme.sh" ]; then
    ACME_BIN="/root/.acme.sh/acme.sh"
fi

if [ -z "$ACME_BIN" ]; then
    log_info "acme.sh is not installed. Installing acme.sh..."
    curl -fsSL https://get.acme.sh | sh -s "email=$ACME_EMAIL"
    ACME_BIN="/root/.acme.sh/acme.sh"
fi

CERT_PATH="/usr/tls/$DOMAIN"
ACME_HOME="/root/.acme.sh"
ACCOUNT_CONF="$ACME_HOME/account.conf"

log_info "Attempting to request SSL certificate for $DOMAIN using acme.sh..."

# Ensure storage directory exists
sudo mkdir -p "$CERT_PATH"

# Fix any stale account email before attempting to register or issue.
if [ -f "$ACCOUNT_CONF" ]; then
    sudo sed -i "s/^ACCOUNT_EMAIL=.*/ACCOUNT_EMAIL='${ACME_EMAIL}'/" "$ACCOUNT_CONF" || true
fi

# Make sure the account email is valid so registration does not fail.
sudo "$ACME_BIN" --update-account -m "$ACME_EMAIL" >/dev/null 2>&1 || true
sudo "$ACME_BIN" --server letsencrypt --register-account -m "$ACME_EMAIL" >/dev/null 2>&1 || true

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
