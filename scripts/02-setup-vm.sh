#!/bin/bash
#############################################################################
# Setup VM with Docker and Dependencies (Patched + IAP SSH)
#
# This script:
# - Installs Docker and Docker Compose (rootless mode)
# - Configures port forwarding via iptables (80->8080, 443->8443)
# - Clones GitHub repository
# - Sets up automatic security updates
#
# Usage: ./scripts/02-setup-vm.sh
#############################################################################
set -e

# Source configuration file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/config.sh"

REPO_URL="https://github.com/jmburke4/capstone-design-manager.git"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Setting Up VM (Patched + IAP SSH)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# SSH into VM using IAP tunneling (required because we only allow SSH via IAP)
echo "Connecting to VM via IAP tunnel..."
gcloud compute ssh $VM_NAME \
        --zone=$ZONE \
        --project=$PROJECT_ID \
        --tunnel-through-iap \
        --command='bash -s' <<'ENDSSH'

set -e
echo "=== VM Setup Script (Rootless Docker) ==="
echo ""

# Update system packages
echo "1. Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
echo " ✓ System updated"

# Install prerequisites
echo ""
echo "2. Installing Rootless Docker prerequisites..."
sudo apt-get install -y -qq \
    uidmap \
    dbus-user-session \
    fuse-overlayfs \
    slirp4netns \
    iptables \
    nftables
echo " ✓ Prerequisites installed"

# Configure subuid/subgid for rootless Docker
echo ""
echo "3. Configuring user namespaces for rootless Docker..."
USERNAME=$(whoami)
if ! grep -q "^${USERNAME}:" /etc/subuid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subuid > /dev/null
fi
if ! grep -q "^${USERNAME}:" /etc/subgid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subgid > /dev/null
fi
echo " ✓ User namespaces configured"

# Fix for GCE Ubuntu
echo ""
echo "4. Fixing iptables/nf_tables for rootless Docker..."
sudo modprobe nf_tables || echo " ✓ nf_tables already loaded"
echo " ✓ iptables and nf_tables ready"

# ====================== Rootless Docker Installation ======================
echo ""
echo "5. Installing Rootless Docker..."
# Handle partial/broken previous installation
if [ -x "$HOME/bin/dockerd" ] && ! systemctl --user is-enabled docker.service >/dev/null 2>&1; then
    echo " Partial/broken rootless Docker installation detected. Cleaning up..."
    systemctl --user stop docker 2>/dev/null || true
    rm -f "$HOME/bin/dockerd"
    rm -f "$HOME/bin/docker"
    echo " ✓ Cleanup completed"
fi

if [ -x "$HOME/bin/docker" ]; then
    echo " ✓ Rootless Docker already installed"
else
    curl -fsSL https://get.docker.com/rootless | sh
    # Add to PATH and environment
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc
    export PATH=$HOME/bin:$PATH
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
    # Enable on boot
    systemctl --user enable docker
    sudo loginctl enable-linger $USER
    echo " ✓ Rootless Docker installed"
fi

# Verify Docker
$HOME/bin/docker --version
echo " ✓ Docker binary found"

echo ""
echo "Verifying Docker daemon is running..."
if ! $HOME/bin/docker info >/dev/null 2>&1; then
    echo " Starting Docker daemon..."
    systemctl --user start docker
    sleep 3
   
    if ! $HOME/bin/docker info >/dev/null 2>&1; then
        echo " ✗ ERROR: Docker daemon failed to start"
        echo " Check logs: journalctl --user -u docker"
        exit 1
    fi
fi
echo " ✓ Docker daemon running (rootless mode)"

# Install Docker Compose
echo ""
echo "6. Installing Docker Compose..."
if $HOME/bin/docker compose version &> /dev/null 2>&1; then
    echo " ✓ Docker Compose already installed"
else
    DOCKER_COMPOSE_VERSION="v2.33.0"
    mkdir -p ~/.docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
        -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    echo " ✓ Docker Compose installed (v2.33.0)"
fi
$HOME/bin/docker compose version
echo " ✓ Docker Compose verified"

# Configure port forwarding for rootless Docker (critical)
echo ""
echo "7. Configuring port forwarding (80->8080, 443->8443)..."
echo "iptables-persistent iptables-persistent/autosave_v4 boolean true" | sudo debconf-set-selections
echo "iptables-persistent iptables-persistent/autosave_v6 boolean true" | sudo debconf-set-selections

sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq iptables-persistent 2>&1 | grep -v "^Selecting\|^Preparing\|^Unpacking\|^Setting up" || echo "iptables-persistent already installed"

sudo mkdir -p /etc/iptables

sudo tee /etc/iptables/rules.v4 > /dev/null << 'EOF'
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# Redirect low ports to rootless nginx ports
-A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
-A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
EOF

sudo iptables-restore < /etc/iptables/rules.v4
sudo systemctl enable netfilter-persistent.service
sudo systemctl start netfilter-persistent.service

# Verify iptables rules are active
echo ""
echo "Verifying iptables rules..."
sleep 2
if sudo iptables -t nat -L PREROUTING -n | grep -q "REDIRECT.*8080"; then
    echo " ✓ Port 80→8080 redirect rule verified"
else
    echo " ⚠ WARNING: iptables redirect rule not found. Attempting to restore..."
    sudo iptables-restore < /etc/iptables/rules.v4
    sleep 2
    if sudo iptables -t nat -L PREROUTING -n | grep -q "REDIRECT.*8080"; then
        echo " ✓ Port 80→8080 redirect rule restored"
    else
        echo " ✗ ERROR: Failed to configure iptables rules. Port 80 will not be reachable."
        exit 1
    fi
fi

if sudo iptables -t nat -L PREROUTING -n | grep -q "REDIRECT.*8443"; then
    echo " ✓ Port 443→8443 redirect rule verified"
else
    echo " ✗ ERROR: Port 443→8443 redirect rule not found"
    exit 1
fi

# Install utilities
echo ""
echo "8. Installing utilities..."
sudo apt-get install -y -qq git curl wget unzip htop
echo " ✓ Utilities installed"

# Install Node.js (required for building frontend)
echo ""
echo "9. Installing Node.js..."
if command -v node &> /dev/null && command -v npm &> /dev/null; then
    echo " ✓ Node.js already installed: $(node --version)"
else
    # Install Node.js 20.x LTS via NodeSource
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y -qq nodejs
    echo " ✓ Node.js installed: $(node --version), npm: $(npm --version)"
fi

# TODO: investigate if this is worth the potential environment messup that updates could cause. (Fallout from updates may mess with app deployment)
# Automatic security updates
echo ""
echo "10. Enabling automatic security updates..."
sudo apt-get install -y -qq unattended-upgrades
echo "unattended-upgrades unattended-upgrades/enable_auto_updates boolean true" | sudo debconf-set-selections
sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure unattended-upgrades
echo " ✓ Automatic updates enabled"

# Clone repository
echo ""
echo "11. Cloning application repository (branch: Cloud-V2)..."
if [ -d "$HOME/capstone" ]; then
    echo " Directory already exists, pulling latest..."
    cd $HOME/capstone
    git fetch origin
    git checkout Cloud-V2
    git pull origin Cloud-V2
else
    git clone -b Cloud-V2 https://github.com/jmburke4/capstone-design-manager.git $HOME/capstone
    cd $HOME/capstone
    echo " ✓ Repository cloned (branch: Cloud-V2)"
fi

# Create directories
echo ""
echo "12. Creating application directories..."
mkdir -p $HOME/capstone/backups
mkdir -p $HOME/capstone/logs
echo " ✓ Directories created"

echo ""
echo "=== VM Setup Complete ==="
echo ""
echo "Docker version: $($HOME/bin/docker --version)"
echo "Docker Compose version: $($HOME/bin/docker compose version)"
echo "Application directory: $HOME/capstone"
echo ""
echo "⚠ IMPORTANT: Log out and log back in if Docker commands fail"
echo ""
ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✓ VM Setup Complete (Patched + IAP SSH)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo " 1. Generate secrets: ./scripts/generate-secrets.sh"
echo " 2. Deploy application: ./scripts/03-deploy-app.sh"
echo ""
