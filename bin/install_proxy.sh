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
CERT_PATH="/usr/tls/$DOMAIN"

log_info "Configuring SSL for Proxy API ($DOMAIN)..."

# Ensure certificates exist
if [ ! -f "$CERT_PATH/$DOMAIN.cer" ] || [ ! -f "$CERT_PATH/$DOMAIN.key" ]; then
    log_error "Certificate files not found in $CERT_PATH. Please run request_ssl.sh first."
    exit 1
fi

# Ensure fullchain.cer exists (construct if missing or incomplete)
# If using ZeroSSL/custom CA, combine domain cert and CA cert
if [ ! -f "$CERT_PATH/fullchain.cer" ] || [ ! -s "$CERT_PATH/fullchain.cer" ]; then
    log_info "Constructing fullchain.cer for $DOMAIN..."
    
    # Simple approach: append CA bundle (if available) to domain cert
    # Assuming CA bundle is named ca.cer if provided separately
    if [ -f "$CERT_PATH/ca.cer" ]; then
        cat "$CERT_PATH/$DOMAIN.cer" "$CERT_PATH/ca.cer" > "$CERT_PATH/fullchain.cer"
    else
        # Just copy if CA not explicitly provided as separate file
        cp "$CERT_PATH/$DOMAIN.cer" "$CERT_PATH/fullchain.cer"
    fi
    log_info "fullchain.cer created."
fi

log_info "Proxy API SSL configuration complete. Certificates ready at $CERT_PATH."
# Here you would add logic to restart your proxy service with these paths
# e.g., systemctl restart my-proxy-service
