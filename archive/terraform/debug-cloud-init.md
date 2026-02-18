# Cloud-Init Debugging Guide

## Check Cloud-Init Status on VM

```bash
# Current status
sudo cloud-init status

# Verbose status
sudo cloud-init status --long

# View full log
sudo cat /var/log/cloud-init-output.log

# View just errors
sudo grep -i error /var/log/cloud-init.log
sudo grep -i error /var/log/cloud-init-output.log

# Check if cloud-init ran at all
sudo systemctl status cloud-init
sudo systemctl status cloud-init-local
```

## Common Issues

### 1. Script Didn't Run
```bash
# Check if user-data was received
sudo cat /var/lib/cloud/instance/user-data.txt

# Should show the cloud-init script
# If empty or missing → Terraform didn't pass it correctly
```

### 2. Download Failed
```bash
# Check network connectivity during boot
sudo journalctl -u cloud-init -b

# Test Terraform download manually
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
```

### 3. Script Error
```bash
# Cloud-init runs with 'set -e' (exit on error)
# One failure stops entire script

# Check where it stopped
sudo tail -100 /var/log/cloud-init-output.log
```

## Manual Fix Script

If cloud-init failed, run this on VM1:

```bash
#!/bin/bash
# Manual setup for VM1 (run as opc user)

echo "=== Installing packages ==="
sudo yum update -y
sudo yum install -y git wget curl vim unzip python3 python3-pip

echo "=== Installing Terraform ==="
cd /tmp
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_1.7.0_linux_amd64.zip

echo "=== Installing Ansible ==="
sudo pip3 install --upgrade pip
sudo pip3 install ansible

echo "=== Setting hostname ==="
sudo hostnamectl set-hostname vm1-control

echo "=== Creating directories ==="
mkdir -p ~/.oci
mkdir -p ~/workspace

echo "=== Verifying installations ==="
echo "Terraform: $(terraform --version | head -1)"
echo "Ansible: $(ansible --version | head -1)"
echo "Python: $(python3 --version)"
echo "Git: $(git --version)"

echo "=== Setup complete! ==="
echo "VM1 is ready for use."
```

## Fix Cloud-Init for Next Time

### Option 1: Check Terraform Template Syntax

```hcl
# In compute.tf, verify:
metadata = {
  user_data = base64encode(templatefile("${path.module}/cloud-init-vm1.sh", {
    hostname = "vm1-control"
  }))
}
```

### Option 2: Test Cloud-Init Script Locally

```bash
# On your Windows machine
cd C:\code\oci-devops-lab\infra\terraform

# Check for syntax errors
bash -n cloud-init-vm1.sh

# If errors found, fix them
```

### Option 3: Simplify Cloud-Init

Create a minimal version that's less likely to fail:

```bash
#!/bin/bash
# Minimal cloud-init for VM1

# Set hostname
hostnamectl set-hostname vm1-control

# Update and install essentials
yum update -y
yum install -y git wget curl vim python3 python3-pip

# Mark complete
echo "Basic setup complete" > /tmp/cloud-init-complete.txt
```

Then install Terraform/Ansible manually after SSH.

## Re-Deploy with Fixed Cloud-Init

If you want to try again with working cloud-init:

```powershell
# On Windows, in terraform directory
terraform destroy -auto-approve
# Wait 5 minutes
terraform plan -out=tfplan
terraform apply tfplan
# Wait 10 minutes for cloud-init
# SSH and check /tmp/cloud-init-complete.txt
```

## Workaround: Skip Cloud-Init

You can comment out the user_data in compute.tf:

```hcl
metadata = {
  ssh_authorized_keys = file(var.ssh_public_key_path)
  # user_data = base64encode(templatefile("${path.module}/cloud-init-vm1.sh", {
  #   hostname = "vm1-control"
  # }))
}
```

Then manually set up the VM after creation. Less "Infrastructure as Code" but gets you working faster.
