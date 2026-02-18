# Cloud-Init OOM Fix

## Problem Identified

**Date:** 2026-02-18  
**Error:** Cloud-init status: error  
**Root Cause:** `yum update -y` was killed during cloud-init execution

### Log Evidence
```
/var/lib/cloud/instance/scripts/part-001: line 10:  3668 Killed                  yum update -y
```

### Why It Happened
- VM has only **1GB RAM** (Always Free tier: VM.Standard.E2.1.Micro)
- `yum update -y` tries to update 200+ packages during first boot
- Oracle Linux repos are large (MySQL, Ksplice, OCI tools, etc.)
- Process consumed too much memory → Linux OOM killer terminated it
- Script has `set -e` → entire cloud-init failed after first error

## Solution Applied

**Removed `yum update -y` from cloud-init scripts:**
- `cloud-init-vm1.sh` ✅ Fixed
- `cloud-init-vm2.sh` ✅ Fixed

**Rationale:**
- System updates should be done AFTER boot when you can monitor/control them
- Cloud-init should only do lightweight, critical setup
- Ansible can handle system updates as a separate playbook

## Manual Setup for Current VMs

Since cloud-init failed, install packages manually:

### VM1 (Control Node) - Run this now:
```bash
# Install essential packages (no full update)
sudo yum install -y git wget curl vim unzip python3 python3-pip

# Install Terraform
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip -o terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_1.7.0_linux_amd64.zip

# Install Ansible
sudo pip3 install --upgrade pip
sudo pip3 install ansible

# Set hostname
sudo hostnamectl set-hostname vm1-control

# Create directories
mkdir -p ~/.oci ~/workspace

# Verify
terraform --version
ansible --version
git --version
```

### VM2 (App Server) - Will be configured by Ansible
- SSH from VM1 to VM2 later
- Ansible will install packages
- No manual work needed on VM2 yet

## System Updates (Do Later)

**After everything is set up**, run updates safely:

```bash
# Check available memory first
free -h

# Update in smaller batches
sudo yum update -y --skip-broken

# Or update specific packages only
sudo yum update -y python3 git curl
```

**Best practice:** Use Ansible playbook for updates:
```yaml
- name: Update system packages safely
  yum:
    name: '*'
    state: latest
    update_cache: yes
  async: 1800  # 30 min timeout
  poll: 10     # Check every 10 seconds
```

## Future Deployments

With the fixed cloud-init scripts, new VMs should work correctly:

```powershell
# On Windows, redeploy with fixed scripts
cd C:\code\oci-devops-lab\infra\terraform
terraform destroy -auto-approve
# Wait 5 minutes
terraform plan -out=tfplan
terraform apply tfplan
# Wait 5-10 minutes for cloud-init
# SSH and verify /tmp/cloud-init-complete.txt exists
```

## Cloud-Init Best Practices for 1GB RAM VMs

**✅ DO:**
- Install specific packages (`yum install -y git curl`)
- Set hostname, create directories
- Configure firewall rules
- Download small files (<50MB)

**❌ DON'T:**
- Run `yum update -y` (too memory-intensive)
- Install large packages (databases, full dev tools)
- Compile software from source
- Run pip installs for heavy packages during cloud-init

**💡 ALTERNATIVE:**
- Use cloud-init for minimal setup
- Use Ansible for heavy lifting after boot
- Schedule system updates during maintenance windows

## Monitoring OOM Events

Check if OOM killer was triggered:

```bash
# View OOM killer logs
sudo dmesg | grep -i 'killed process'
sudo grep -i 'out of memory' /var/log/messages

# Check current memory usage
free -h
top -o %MEM
```

## Lessons Learned

1. **Always Free VMs (1GB RAM) need careful cloud-init design**
2. **System updates should be separated from initial provisioning**
3. **Use `set -e` cautiously** - one failure kills entire script
4. **Test cloud-init scripts on minimal VMs before production**
5. **Ansible is better for complex configuration** than cloud-init

---

**Status:** Issue resolved. Future deployments will use lightweight cloud-init. Current VMs need manual setup.
