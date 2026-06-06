# Linux Toolbox

A collection of Bash tools for system administration tasks.

## Deployment & Usage

### One-Line Installation
Run the following command to install/update and run the Linux Toolbox:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/UtopiaLee/CharosTool/master/bootstrap.sh)
```

## Tools
All tools are located in `bin/`.

### 1. SSL Certificate Request
Requests a certificate for a domain using `acme.sh` and installs it to `/usr/tls/<domain>`.
```bash
/opt/linux-toolbox/bin/request_ssl.sh [domain]
```

### 2. Proxy API Installation
Configures SSL for the Proxy API.
```bash
/opt/linux-toolbox/bin/install_proxy.sh [domain]
```
