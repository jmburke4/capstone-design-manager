#!/bin/bash
#############################################################################
# Setup VM with Docker and Dependencies
#
# This script:
# - Installs Docker and Docker Compose (rootless mode)
# - Configures firewall (ufw)
# - Clones GitHub repository
# - Sets up automatic security updates
#
# Usage: ./scripts/02-setup-vm.sh
#############################################################################
set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-b"
VM_NAME="capstone-prod-vm"
REPO_URL="https://github.com/jmburke4/capstone-design-manager.git"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Setting Up VM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will SSH into the VM and install Docker, Docker Compose, etc."
echo ""

# SSH into VM and run setup commands
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='bash -s' <<'ENDSSH'
set -e

echo "=== VM Setup Script ==="
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
echo " Configuring user namespaces for rootless Docker..."
USERNAME=$(whoami)
if ! grep -q "^${USERNAME}:" /etc/subuid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subuid > /dev/null
fi
if ! grep -q "^${USERNAME}:" /etc/subgid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subgid > /dev/null
fi
echo " ✓ User namespaces configured"

# Fix for GCE Ubuntu (nf_tables requirement)
echo ""
echo " Fixing iptables/nf_tables for rootless Docker..."
sudo modprobe nf_tables || echo " ✓ nf_tables already loaded"
echo " ✓ iptables and nf_tables ready"

# ====================== FIXED: Rootless Docker Installation ======================
echo ""
echo " Installing Rootless Docker..."

# Handle partial/broken previous installation (this was causing your error)
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

# Verify Docker installation
$HOME/bin/docker --version
echo " ✓ Docker binary found"

# Verify Docker daemon is running
echo ""
echo "Verifying Docker daemon is running..."
if ! $HOME/bin/docker info >/dev/null 2>&1; then
    echo "  Starting Docker daemon..."
    systemctl --user start docker
    sleep 3
    
    # Retry check
    if ! $HOME/bin/docker info >/dev/null 2>&1; then
        echo " ✗ ERROR: Docker daemon failed to start"
        echo " Check logs: journalctl --user -u docker"
        exit 1
    fi
fi
echo " ✓ Docker daemon running (rootless mode)"

# Install Docker Compose
echo ""
echo "3. Installing Docker Compose..."
if command -v docker-compose &> /dev/null || $HOME/bin/docker compose version &> /dev/null 2>&1; then
    echo " ✓ Docker Compose already installed"
else
    DOCKER_COMPOSE_VERSION="v2.24.0"
    mkdir -p ~/.docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
        -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    echo " ✓ Docker Compose installed"
fi
$HOME/bin/docker compose version
echo " ✓ Docker Compose verified"

# Configure port forwarding (80->8080, 443->8443)
echo ""
echo "4. Configuring port forwarding for rootless Docker..."

# Install iptables-persistent for rule persistence
sudo apt-get install -y -qq iptables-persistent || echo "iptables-persistent already installed"

# Create iptables rules directory
sudo mkdir -p /etc/iptables

# Create persistent iptables rules with proper NAT configuration
sudo tee /etc/iptables/rules.v4 > /dev/null << 'EOF'
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
# Redirect port 80 to 8080 for rootless nginx
-A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
# Redirect port 443 to 8443 for rootless nginx SSL
-A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
EOF

# Load the rules immediately
sudo iptables-restore < /etc/iptables/rules.v4

# Enable netfilter-persistent service (replaces deprecated rc.local)
sudo systemctl enable netfilter-persistent.service
sudo systemctl start netfilter-persistent.service

echo " ✓ Port forwarding configured and persisted (80->8080, 443->8443)"

# Install utilities
echo ""
echo "5. Installing utilities..."
sudo apt-get install -y -qq git curl wget unzip htop
echo " ✓ Utilities installed"

# Configure firewall
echo ""
echo "6. Configuring UFW firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
echo " ✓ Firewall configured"

# Automatic security updates
echo ""
echo "7. Enabling automatic security updates..."
sudo apt-get install -y -qq unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
echo " ✓ Automatic updates enabled"

# Clone repository
echo ""
echo "8. Cloning application repository (branch: Cloud-V2)..."
if [ -d "$HOME/capstone" ]; then
    echo " ℹ Directory already exists, pulling latest..."
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
echo "9. Creating application directories..."
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
echo "⚠ IMPORTANT: Log out and log back in (or run: newgrp docker) for full Docker access"
echo ""

ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " ✓ VM Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "VM is ready for deployment!"
echo ""
echo "Next steps:"
echo " 1. Generate secrets: ./scripts/generate-secrets.sh"
echo " 2. Review .env files"
echo " 3. Deploy application: ./scripts/03-deploy-app.sh"
echo ""
