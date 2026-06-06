# Linux Toolbox

A collection of Bash tools for system administration tasks.

## Deployment

### Initial Setup
Clone the repository onto your Linux server:
```bash
sudo git clone https://github.com/UtopiaLee/CharosTool.git /opt/linux-toolbox
```

### Updating
To pull the latest changes from GitHub:
```bash
/opt/linux-toolbox/bin/update_toolbox.sh
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
