#!/bin/bash

#############################################################################
# Setup VM with Docker and Dependencies
#
# This script:
# - Installs Docker and Docker Compose
# - Configures firewall (ufw)
# - Clones GitHub repository
# - Sets up automatic security updates
#
# Usage: ./scripts/02-setup-vm.sh
#############################################################################

set -e

PROJECT_ID="capstone-design-app-prod"
ZONE="us-central1-a"
VM_NAME="capstone-prod-vm"
REPO_URL="https://github.com/jmburke4/capstone-design-manager.git"
APP_DIR="/home/\$USER/capstone"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setting Up VM"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will SSH into the VM and install Docker, Docker Compose, etc."
echo ""

# SSH into VM and run setup commands
# this step will probably prompt for your ssh passphrase, which you would have configued when you set up ssh connect to the gcloud compute engine from the computer that you are deploying from
# I guess that setting up gcloud compute engine account would be a pre-req to 
gcloud compute ssh $VM_NAME --zone=$ZONE --project=$PROJECT_ID --command='bash -s' << 'ENDSSH'

set -e

echo "=== VM Setup Script ==="
echo ""

# Update system packages
echo "1. Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
echo "  ✓ System updated"

# Install Rootless Docker
echo ""
echo "2. Installing Rootless Docker..."

# Install prerequisites for rootless Docker
sudo apt-get install -y -qq \
    uidmap \
    dbus-user-session \
    fuse-overlayfs \
    slirp4netns

# Configure subuid/subgid for rootless Docker (CRITICAL for GCE OS Login)
echo "  Configuring user namespaces for rootless Docker..."
USERNAME=$(whoami)
if ! grep -q "^${USERNAME}:" /etc/subuid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subuid > /dev/null
fi
if ! grep -q "^${USERNAME}:" /etc/subgid 2>/dev/null; then
    echo "${USERNAME}:100000:65536" | sudo tee -a /etc/subgid > /dev/null
fi
echo "  ✓ User namespaces configured (subuid/subgid ranges set)"

# Install Docker in rootless mode
if command -v docker &> /dev/null; then
    echo "  ✓ Docker already installed"
else
    # Download and run rootless Docker installer
    curl -fsSL https://get.docker.com/rootless | sh
    
    # Add Docker to PATH
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc
    export PATH=$HOME/bin:$PATH
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
    
    # Enable Docker to start on boot
    systemctl --user enable docker
    sudo loginctl enable-linger $USER
    
    echo "  ✓ Rootless Docker installed"
fi

# Verify Docker
$HOME/bin/docker --version
echo "  ✓ Docker verified (running as $(whoami), rootless)"

# Install Docker Compose
echo ""
echo "3. Installing Docker Compose..."
if command -v docker-compose &> /dev/null || $HOME/bin/docker compose version &> /dev/null 2>&1; then
    echo "  ✓ Docker Compose already installed"
else
    # Install Docker Compose V2
    DOCKER_COMPOSE_VERSION="v2.24.0"
    mkdir -p ~/.docker/cli-plugins
    curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" \
        -o ~/.docker/cli-plugins/docker-compose
    chmod +x ~/.docker/cli-plugins/docker-compose
    
    echo "  ✓ Docker Compose installed"
fi

$HOME/bin/docker compose version
echo "  ✓ Docker Compose verified"

# Configure port forwarding (80->8080, 443->8443)
echo ""
echo "3.5. Configuring port forwarding for rootless Docker..."

# Rootless Docker can't bind to ports < 1024
# Use iptables to redirect 80->8080 and 443->8443

sudo tee /etc/rc.local > /dev/null << 'PORTFORWARD'
#!/bin/bash
# Redirect privileged ports to non-privileged ports for rootless Docker
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443
exit 0
PORTFORWARD

sudo chmod +x /etc/rc.local

# Apply rules now
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8443

echo "  ✓ Port forwarding configured (80->8080, 443->8443)"

# Install additional utilities
echo ""
echo "4. Installing utilities..."
sudo apt-get install -y -qq git curl wget unzip htop
echo "  ✓ Utilities installed"

# Configure firewall
echo ""
echo "5. Configuring UFW firewall..."
sudo ufw --force enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
echo "  ✓ Firewall configured"

# Enable automatic security updates
echo ""
echo "6. Enabling automatic security updates..."
sudo apt-get install -y -qq unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
echo "  ✓ Automatic updates enabled"

# Clone repository
echo ""
echo "7. Cloning application repository (branch: Cloud-V2)..."
if [ -d "$HOME/capstone" ]; then
    echo "  ℹ Directory already exists, pulling latest..."
    cd $HOME/capstone
    git fetch origin
    git checkout Cloud-V2
    git pull origin Cloud-V2
else
    git clone -b Cloud-V2 https://github.com/jmburke4/capstone-design-manager.git $HOME/capstone
    cd $HOME/capstone
    echo "  ✓ Repository cloned (branch: Cloud-V2)"
fi

# Create necessary directories
echo ""
echo "8. Creating application directories..."
mkdir -p $HOME/capstone/backups
mkdir -p $HOME/capstone/logs
echo "  ✓ Directories created"

echo ""
echo "=== VM Setup Complete ==="
echo ""
echo "Docker version: $(docker --version)"
echo "Docker Compose version: $(docker compose version)"
echo "Application directory: $HOME/capstone"
echo ""
echo "⚠ IMPORTANT: Log out and log back in for Docker group membership to take effect"
echo "   Or run: newgrp docker"
echo ""

ENDSSH

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✓ VM Setup Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "VM is ready for deployment!"
echo ""
echo "Next steps:"
echo "  1. Generate secrets: ./scripts/generate-secrets.sh"
echo "  2. Review .env files"
echo "  3. Deploy application: ./scripts/03-deploy-app.sh"
echo ""
