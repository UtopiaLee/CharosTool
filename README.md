# Linux Toolbox

A collection of Bash tools for system administration tasks.

## Deployment & Usage

### 1. Initial Setup
Clone the repository onto your Linux server:
```bash
sudo git clone https://github.com/UtopiaLee/CharosTool.git /opt/linux-toolbox
```

### 2. All-in-One Installation
For a streamlined experience, run the main installer script. It will interactively guide you through requesting an SSL certificate and configuring your Proxy API:
```bash
cd /opt/linux-toolbox
sudo ./install.sh
```

### 3. Updating
To pull the latest changes from GitHub:
```bash
/opt/linux-toolbox/bin/update_toolbox.sh
```
