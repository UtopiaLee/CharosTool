#!/usr/bin/env bash

# Common library for Linux Toolbox
# Source this file in other scripts

# Log messages
log_info() {
    logger -t linux-toolbox "[INFO] $1"
    echo "[INFO] $1"
}

log_error() {
    logger -t linux-toolbox "[ERROR] $1"
    echo "[ERROR] $1" >&2
}
