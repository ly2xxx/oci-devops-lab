#!/bin/bash
# Manual setup script for VM1 (Control Node)
# Run this on VM1 if cloud-init failed
# Usage: bash setup-vm1-manual.sh

set -e

echo "========================================="
echo "VM1 Manual Setup Script"
echo "========================================="
echo ""

# Check if running as opc
if [ "$USER" != "opc" ]; then
    echo "⚠️  Warning: This script should run as 'opc' user"
    echo "Current user: $USER"
fi

# Update system
echo "[1/6] Updating system packages..."
sudo yum update -y

# Install basic tools
echo "[2/6] Installing basic tools (git, wget, curl, vim, python3)..."
sudo yum install -y git wget curl vim unzip python3 python3-pip

# Install Terraform
echo "[3/6] Installing Terraform 1.7.0..."
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip -o terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_1.7.0_linux_amd64.zip

# Install Ansible
echo "[4/6] Installing Ansible via pip..."
sudo pip3 install --upgrade pip
sudo pip3 install ansible

# Set hostname
echo "[5/6] Setting hostname to vm1-control..."
sudo hostnamectl set-hostname vm1-control

# Create directories
echo "[6/6] Creating workspace directories..."
mkdir -p ~/.oci
mkdir -p ~/workspace

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Installed versions:"
echo "  Terraform: $(terraform --version | head -1)"
echo "  Ansible: $(ansible --version | head -1)"
echo "  Python: $(python3 --version)"
echo "  Git: $(git --version)"
echo ""
echo "Next steps:"
echo "  1. Upload your OCI API key to ~/.oci/"
echo "  2. Clone your repo: git clone <repo-url>"
echo "  3. Configure Ansible inventory"
echo ""
