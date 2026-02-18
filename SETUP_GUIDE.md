# OCI DevOps Lab - Detailed Setup Guide

This guide walks you through setting up the complete lab environment step by step.

---

## 🎯 Tonight's Goal

Get VM1 and VM2 running on OCI with Terraform, then configure VM2 with Ansible to serve a demo web app.

**Timeline:** 2-3 hours

---

## Phase 1: OCI Prerequisites (15 minutes)

### Step 1.1: Get OCI API Credentials

1. **Log into OCI Console**
   - Go to https://cloud.oracle.com/
   - Sign in with your account

2. **Get Your OCIDs**
   Navigate to: **Profile (top right) → Tenancy: <your-tenancy-name>**
   
   Note down:
   - **Tenancy OCID:** `ocid1.tenancy.oc1..aaaaaa...`
   - **Region:** e.g., `uk-london-1`, `eu-frankfurt-1`

3. **Get User OCID**
   Navigate to: **Identity → Users → Your Username**
   
   Copy: **User OCID:** `ocid1.user.oc1..aaaaaa...`

4. **Generate API Key Pair**
   
   On your **Windows machine**, open Git Bash or PowerShell:
   ```bash
   # Create .oci directory
   mkdir -p ~/.oci
   cd ~/.oci
   
   # Generate key pair in PEM format (REQUIRED by OCI!)
   ssh-keygen -t rsa -b 4096 -m PEM -f oci_api_key -N ""
   
   # Rename to .pem extension
   mv oci_api_key oci_api_key.pem
   
   # This creates:
   # oci_api_key.pem (private key in PEM format)
   # oci_api_key.pub (public key)
   ```
   
   **⚠️ Critical:** The `-m PEM` flag is required! OCI does NOT accept OpenSSH format keys.
   
   **Verify correct format:**
   ```bash
   head -1 ~/.oci/oci_api_key.pem
   # Should show: -----BEGIN PRIVATE KEY-----
   # NOT: -----BEGIN OPENSSH PRIVATE KEY-----
   ```

5. **Add Public Key to OCI**
   - In OCI Console: **Identity → Users → Your Username → API Keys**
   - Click **Add API Key**
   - Choose **Paste Public Key**
   - Open `~/.oci/oci_api_key.pub` (or `C:\Users\vl\.oci\oci_api_key.pub` on Windows) and paste contents
   - Click **Add**
   - **Copy the fingerprint** shown (you'll need this)
   
   **Verify PEM format:**
   ```bash
   # Your private key should start with:
   head -1 ~/.oci/oci_api_key.pem
   # Should output: -----BEGIN PRIVATE KEY-----
   # NOT: -----BEGIN OPENSSH PRIVATE KEY-----
   ```

### Step 1.2: Configure SSH Key for VM Access

```powershell
# Generate SSH key for VM access (if you don't have one)
cd C:\Users\vl\.ssh
ssh-keygen -t rsa -b 4096 -f id_rsa -N ""

# This creates:
# id_rsa (private key)
# id_rsa.pub (public key for VMs)
```

---

## Phase 2: Configure Terraform (10 minutes)

### Step 2.1: Install Terraform (if not installed)

```powershell
# Using Chocolatey - (Run as administrator)
choco install terraform -y

# Verify
terraform version
```

### Step 2.2: Configure Terraform Variables

```powershell
cd C:\code\oci-devops-lab\infra\terraform

# Copy example file
copy terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your actual values
notepad terraform.tfvars
```

**Fill in your values:**
```hcl
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaa..."  # From Step 1.1
user_ocid        = "ocid1.user.oc1..aaaaaa..."     # From Step 1.1
fingerprint      = "xx:xx:xx:..."                  # From Step 1.1 (API key)
private_key_path = "C:\\Users\\vl\\.oci\\oci_api_key"
region           = "uk-london-1"                    # Your region

compartment_ocid = "ocid1.tenancy.oc1..aaaaaa..."  # Same as tenancy_ocid

ssh_public_key_path = "C:\\Users\\vl\\.ssh\\id_rsa.pub"

availability_domain = 1  # Try 1, 2, or 3 based on your region

# Leave image_ocid empty - Terraform will auto-fetch latest Oracle Linux 8
instance_image_ocid = ""
```

### Step 2.3: Get Image OCID (Alternative)

If auto-fetch doesn't work, manually get the image OCID:

1. In OCI Console: **Compute → Images**
2. Find **Oracle Linux 8**
3. Click on it
4. Copy **OCID**
5. Paste into `terraform.tfvars`: `instance_image_ocid = "ocid1.image..."`

---

## Phase 3: Deploy Infrastructure with Terraform (30 minutes)

### Step 3.1: Initialize Terraform

```powershell
cd C:\code\oci-devops-lab\infra\terraform

# Initialize (downloads OCI provider)
terraform init

# Should see: "Terraform has been successfully initialized!"
```

### Step 3.2: Plan Infrastructure

```powershell
# Preview what will be created
terraform plan -out=tfplan
(terraform show tfplan > tfplan.txt)
# Review the output - should show:
# - VCN, subnets, internet gateway, route tables
# - Security lists
# - 2 compute instances (VM1, VM2)
```

### Step 3.3: Apply Infrastructure

```powershell
# Create infrastructure
terraform apply tfplan

# Type 'yes' when prompted
# Wait ~5-10 minutes for VMs to provision
```

### Step 3.4: Get Outputs

```powershell
# Show all outputs
terraform output

# Get specific values
terraform output vm1_public_ip
terraform output vm2_public_ip
terraform output ssh_to_vm1
terraform output ansible_inventory
```

**Save these IPs - you'll need them!**

---

## Phase 4: Configure VM1 (Control Node) (30 minutes)

### Step 4.1: SSH to VM1

```powershell
# Get VM1 IP from Terraform output
terraform output vm1_public_ip

# SSH (replace with actual IP)
ssh -i C:\Users\vl\.ssh\id_rsa opc@<VM1_PUBLIC_IP>
```

**Troubleshooting:**
- If connection refused: Wait 2-3 minutes for cloud-init to complete
- Check security list allows SSH from your IP
- Verify your public IP: `curl ifconfig.me`

### Step 4.2: Verify Cloud-Init Completed

```bash
# On VM1
cat /tmp/cloud-init-complete.txt
# Should say: "VM1 Control Node initialization complete!"

# Check installed tools
terraform version
ansible --version
git --version
```

### Step 4.3: Clone Repo to VM1

```bash
cd ~
git clone https://github.com/ly2xxx/oci-devops-lab.git
cd oci-devops-lab
```

### Step 4.4: Configure OCI Credentials on VM1

```bash
mkdir ~/.oci

# Copy your OCI API key to VM1
# On Windows machine, run:
# scp -i C:\Users\vl\.ssh\id_rsa C:\Users\vl\.oci\oci_api_key opc@<VM1_IP>:~/.oci/

# On VM1:
chmod 600 ~/.oci/oci_api_key

# Create OCI config file
vi ~/.oci/config
```

**Paste this (replace with your values):**
```ini
[DEFAULT]
user=ocid1.user.oc1..aaaaaa...
fingerprint=xx:xx:xx:...
key_file=/home/opc/.oci/oci_api_key
tenancy=ocid1.tenancy.oc1..aaaaaa...
region=uk-london-1
```

### Step 4.5: Test Terraform on VM1

```bash
cd ~/oci-devops-lab/infra/terraform

# Copy terraform.tfvars from Windows
# OR recreate it on VM1

# Test
terraform plan
# Should show: No changes (infrastructure already exists)
```

---

## Phase 5: Configure Ansible Inventory (15 minutes)

### Step 5.1: Update Inventory File

On **VM1**:

```bash
cd ~/oci-devops-lab/config/ansible

# Get Terraform outputs for IPs
cd ~/oci-devops-lab/infra/terraform
terraform output ansible_inventory

# Copy the output to inventory file
vi inventory/hosts.yml
```

**Replace placeholders with actual IPs:**
```yaml
all:
  vars:
    ansible_user: opc
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    ansible_python_interpreter: /usr/bin/python3

  children:
    control:
      hosts:
        vm1:
          ansible_host: <VM1_PUBLIC_IP>
          
    app_servers:
      hosts:
        vm2:
          ansible_host: <VM2_PRIVATE_IP>
```

### Step 5.2: Test Ansible Connection

```bash
cd ~/oci-devops-lab/config/ansible

# Test ping
ansible all -i inventory/hosts.yml -m ping

# Should get:
# vm1 | SUCCESS => ...
# vm2 | SUCCESS => ...
```

**Troubleshooting:**
- If VM2 unreachable from VM1:
  - Check security list allows SSH from VCN CIDR (10.0.0.0/16)
  - Verify VM2's private IP
  - Test: `ssh opc@<VM2_PRIVATE_IP>` from VM1

---

## Phase 6: Deploy App with Ansible (30 minutes)

### Step 6.1: Run Base Configuration Playbook

```bash
cd ~/oci-devops-lab/config/ansible

# Configure VM2 (install Nginx, create users, harden SSH)
ansible-playbook -i inventory/hosts.yml playbooks/base-config.yml

# Should complete without errors
```

### Step 6.2: Deploy Demo App

```bash
# Deploy Flask app to VM2
ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml

# Should complete successfully
```

### Step 6.3: Verify App is Running

**From VM1:**
```bash
# Check if app is running on VM2
curl http://<VM2_PRIVATE_IP>

# Should return HTML
```

**From your browser:**
- Go to: `http://<VM2_PUBLIC_IP>`
- Should see: **OCI DevOps Lab** demo page

---

## Phase 7: Octopus Deploy Setup (Tomorrow)

### Step 7.1: Sign Up for Octopus Cloud

1. Go to https://octopus.com/start
2. Create free cloud instance
3. Choose a unique instance name (e.g., `yangdevops`)
4. Your instance URL: `https://yangdevops.octopus.app`

### Step 7.2: Install Tentacle on VMs

**On VM1 and VM2:**

```bash
# Download Tentacle
cd /tmp
wget https://octopus.com/downloads/latest/Linux_x64TarGz/OctopusTentacle
tar xzf OctopusTentacle -C /opt

# Install
sudo /opt/tentacle/configure
# Follow wizard to register with Octopus Cloud
```

### Step 7.3: Create Octopus Project

In Octopus Cloud:
1. **Projects → Add Project:** "OCI DevOps Lab"
2. **Infrastructure → Environments:**
   - Add: `Dev` environment
3. **Infrastructure → Deployment Targets:**
   - Add VM2 as target (role: `app-server`)

### Step 7.4: Define Deployment Process

**Step 1: Run Terraform**
- Target: VM1 (control node)
- Script:
  ```bash
  cd ~/oci-devops-lab/infra/terraform
  terraform apply -auto-approve
  ```

**Step 2: Configure Servers**
- Target: VM1
- Script:
  ```bash
  cd ~/oci-devops-lab/config/ansible
  ansible-playbook -i inventory/hosts.yml playbooks/base-config.yml
  ```

**Step 3: Deploy App**
- Target: VM1
- Script:
  ```bash
  cd ~/oci-devops-lab/config/ansible
  ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
  ```

### Step 7.5: Test Deployment

1. Create Release in Octopus
2. Deploy to Dev
3. Verify app updated on VM2

---

## 🎉 Success Checklist

- [ ] Terraform provisions VCN, VM1, VM2 on OCI
- [ ] Can SSH to VM1 from Windows
- [ ] VM1 has Terraform + Ansible installed
- [ ] Ansible can connect to VM2 from VM1
- [ ] Base config playbook runs successfully
- [ ] Demo app deployed and accessible via browser
- [ ] Octopus Tentacle registered (tomorrow)
- [ ] End-to-end deployment works via Octopus (tomorrow)

---

## 📞 Need Help?

**Common Issues:**

1. **Terraform "Authentication failed"**
   - Verify fingerprint matches OCI console
   - Check key file permissions: `chmod 600 ~/.oci/oci_api_key`

2. **VM won't start**
   - Check Always Free capacity in your region
   - Try different availability domain (1, 2, or 3)

3. **Ansible can't connect**
   - Verify security list allows SSH from VCN
   - Check inventory has correct IPs

4. **App not accessible**
   - Check VM2 firewall: `sudo firewall-cmd --list-all`
   - Verify Nginx is running: `sudo systemctl status nginx`
   - Check app service: `sudo systemctl status demoapp`

---

**Next:** Continue to Octopus Deploy integration or add VM3!
