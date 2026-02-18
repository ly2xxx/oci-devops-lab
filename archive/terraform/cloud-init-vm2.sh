#!/bin/bash
# Cloud-init script for VM2 (App Server)

set -e

# Set hostname
hostnamectl set-hostname ${hostname}

# Skip full system update during cloud-init (causes OOM on 1GB RAM)
# Update system manually after boot or via Ansible

# Install basic packages
yum install -y \
    git \
    wget \
    curl \
    vim \
    python3 \
    python3-pip

# Prepare for Nginx (will be installed by Ansible)
# Just ensure system is ready

# Configure firewall
firewall-cmd --permanent --add-service=ssh
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

echo "VM2 App Server initialization complete!" > /tmp/cloud-init-complete.txt
