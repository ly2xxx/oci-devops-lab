#!/bin/bash
# Cloud-init script for VM1 (Control Node)

set -e

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
yum update -y

# Install basic tools
yum install -y \
    git \
    wget \
    curl \
    vim \
    unzip \
    python3 \
    python3-pip

# Install Terraform
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip -o terraform_1.7.0_linux_amd64.zip
mv terraform /usr/local/bin/
chmod +x /usr/local/bin/terraform
rm terraform_1.7.0_linux_amd64.zip

# Install Ansible
pip3 install --upgrade pip
pip3 install ansible

# Create .oci directory for OCI credentials
mkdir -p /home/opc/.oci
chown -R opc:opc /home/opc/.oci

# Configure firewall
firewall-cmd --permanent --add-service=ssh
firewall-cmd --reload

# Create workspace directory
mkdir -p /home/opc/workspace
chown -R opc:opc /home/opc/workspace

echo "VM1 Control Node initialization complete!" > /tmp/cloud-init-complete.txt
