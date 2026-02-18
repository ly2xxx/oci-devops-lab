#!/bin/bash
# Quick setup script for VM1 after failed provisioning
# Run this on VM1: bash ~/setup-vm1.sh

set -e

echo "========================================="
echo "VM1 Manual Setup (skips yum update)"
echo "========================================="
echo ""

echo "[1/5] Installing basic packages..."
sudo yum install -y git wget curl vim unzip python3-pip

echo "[2/5] Installing Terraform 1.7.5..."
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip -o terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm -f terraform_1.7.5_linux_amd64.zip

echo "[3/5] Installing Ansible..."
sudo pip3 install --upgrade pip
sudo pip3 install ansible

echo "[4/5] Creating workspace directory..."
mkdir -p ~/workspace

echo "[5/5] Generating SSH key for Ansible..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

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
echo "  cd ~/workspace"
echo "  # Follow SETUP_GUIDE.md Phase 3"
echo ""
