# OCI DevOps Lab - Terraform + Ansible + Octopus

**Goal:** Build a complete DevOps pipeline using Terraform, Ansible, and Octopus Deploy on Oracle Cloud Infrastructure (OCI) Always Free tier.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│          Oracle Cloud Infrastructure            │
│                                                 │
│  ┌──────────────┐         ┌──────────────┐    │
│  │   VM1        │         │   VM2        │    │
│  │ Control Node │────────▶│  App Server  │    │
│  │              │  SSH    │              │    │
│  │ • Terraform  │ Ansible │ • Nginx      │    │
│  │ • Ansible    │         │ • Demo App   │    │
│  │ • Git        │         │              │    │
│  │ • Octopus    │         │ • Octopus    │    │
│  │   Tentacle   │         │   Tentacle   │    │
│  └──────────────┘         └──────────────┘    │
│         │                                       │
│         │ (Optional VM3: DB/App)               │
│         └─────────────────────────────         │
└─────────────────────────────────────────────────┘
         ▲                    ▲
         │                    │
    ┌────┴────┐         ┌─────┴──────┐
    │ GitHub  │         │  Octopus   │
    │  Repo   │         │   Cloud    │
    └─────────┘         └────────────┘
```

---

## 📋 Phase-by-Phase Implementation

### **Phase 1: OCI Setup & Terraform Foundation** (Tonight)
**Time:** 1-2 hours
https://signup.oraclecloud.com/ 
1. **OCI Account Prep**
   - [ ] Log into OCI Console
   - [ ] Note down: Tenancy OCID, User OCID, Region
   - [ ] Create API key pair for Terraform authentication
   - [ ] Add public key to OCI user settings
   - [ ] Save private key as `~/.oci/oci_api_key.pem`

2. **Local Terraform Setup**
   - [ ] Install Terraform CLI (if not already installed)
   - [ ] Test: `terraform version`
   - [ ] Configure OCI provider credentials in `terraform.tfvars`

3. **Create Networking Infrastructure**
   - [ ] Initialize Terraform: `cd infra/terraform && terraform init`
   - [ ] Review plan: `terraform plan`
   - [ ] Apply: `terraform apply`
   - [ ] Creates: VCN, subnets, internet gateway, route tables, security lists

4. **Create VM1 (Control Node)**
   - [ ] Provision Oracle Linux Always Free VM
   - [ ] Assign public IP
   - [ ] Configure security list for SSH (port 22)
   - [ ] Get public IP from Terraform output
   - [ ] SSH test: `ssh -i ~/.ssh/id_rsa opc@<VM1_PUBLIC_IP>`

**Deliverable:** VM1 running and accessible via SSH

---

### **Phase 2: Control Node Configuration** (Tonight)
**Time:** 30-45 minutes

1. **SSH into VM1**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@<VM1_PUBLIC_IP>
   ```

2. **Install Base Tools**
   ```bash
   sudo yum update -y
   sudo yum install -y git python3 python3-pip
   ```

3. **Install Terraform on VM1**
   ```bash
   wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
   sudo unzip terraform_1.7.0_linux_amd64.zip -d /usr/local/bin/
   terraform version
   ```

4. **Install Ansible**
   ```bash
   sudo pip3 install ansible
   ansible --version
   ```

5. **Clone This Repo to VM1**
   ```bash
   cd ~
   git clone https://github.com/ly2xxx/oci-devops-lab.git
   cd oci-devops-lab
   ```

6. **Configure OCI Credentials on VM1**
   ```bash
   mkdir ~/.oci
   # Upload your OCI API key and config
   # Test: cd infra/terraform && terraform plan
   ```

**Deliverable:** VM1 is ready to run Terraform and Ansible

---

### **Phase 3: Deploy VM2 (App Server)** (Tonight)
**Time:** 30 minutes

1. **Add VM2 to Terraform Config**
   - [ ] Edit `infra/terraform/compute.tf`
   - [ ] Add VM2 definition (Always Free shape)
   - [ ] Configure security list for HTTP (80), HTTPS (443)

2. **Apply Terraform from VM1**
   ```bash
   cd ~/oci-devops-lab/infra/terraform
   terraform plan
   terraform apply
   ```

3. **Verify VM2**
   - [ ] Check Terraform outputs for VM2 IP
   - [ ] SSH test from VM1: `ssh opc@<VM2_PRIVATE_IP>`
   - [ ] Update Ansible inventory with VM2 IP

**Deliverable:** VM2 provisioned and accessible from VM1

---

### **Phase 4: Ansible Configuration** (Tonight/Tomorrow)
**Time:** 1 hour

1. **Create Ansible Inventory**
   - [ ] Edit `config/ansible/inventory/hosts.yml`
   - [ ] Add VM2 IP and SSH details

2. **Test Ansible Connection**
   ```bash
   cd ~/oci-devops-lab/config/ansible
   ansible all -i inventory/hosts.yml -m ping
   ```

3. **Run Base Configuration Playbook**
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/base-config.yml
   ```
   - Installs: Nginx, Python, firewall rules
   - Hardens SSH
   - Creates app user

4. **Deploy Demo App**
   ```bash
   ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
   ```
   - Copies Flask/Node app to VM2
   - Configures Nginx reverse proxy
   - Starts app service

5. **Verify App**
   - [ ] Open browser: `http://<VM2_PUBLIC_IP>`
   - [ ] Should see demo app homepage

**Deliverable:** VM2 fully configured with running web app

---

### **Phase 5: Octopus Deploy Integration** (Tomorrow)
**Time:** 1-2 hours

1. **Sign Up for Octopus Cloud**
   - [ ] Go to https://octopus.com/start
   - [ ] Create free cloud instance
   - [ ] Note: Instance URL and API key

2. **Install Octopus Tentacle on VM1 & VM2**
   ```bash
   # On each VM:
   wget https://octopus.com/downloads/latest/Linux_x64TarGz/OctopusTentacle
   # Follow installation steps
   # Register with Octopus Cloud
   ```

3. **Configure Octopus Project**
   - [ ] Create Project: "OCI DevOps Lab"
   - [ ] Add Environments: Dev, Test
   - [ ] Register VM2 as deployment target (Dev environment)
   - [ ] (Optional) Register VM3 as Test environment

4. **Create Deployment Process**
   - **Step 1:** Run Terraform (on VM1)
     - Executes: `cd ~/oci-devops-lab/infra/terraform && terraform apply -auto-approve`
   - **Step 2:** Run Ansible Base Config (on VM1)
     - Executes: `ansible-playbook -i inventory playbooks/base-config.yml`
   - **Step 3:** Deploy App (on VM1)
     - Executes: `ansible-playbook -i inventory playbooks/deploy-app.yml`

5. **Test Deployment**
   - [ ] Create release in Octopus
   - [ ] Deploy to Dev
   - [ ] Verify app is updated
   - [ ] Practice rollback

**Deliverable:** End-to-end automated deployment via Octopus

---

### **Phase 6: CI/CD Integration** (Optional - Tomorrow)
**Time:** 1 hour

1. **Set Up GitHub Actions**
   - [ ] Create `.github/workflows/ci.yml`
   - [ ] On push to `main`: package app, create Octopus release
   - [ ] Auto-deploy to Dev environment

2. **Test Full Pipeline**
   - [ ] Make change to app code
   - [ ] Push to GitHub
   - [ ] GitHub Action triggers
   - [ ] Octopus auto-deploys
   - [ ] Verify change on VM2

**Deliverable:** Fully automated CI/CD pipeline

---

## 📁 Repository Structure

```
oci-devops-lab/
├── README.md                    # This file
├── SETUP_GUIDE.md              # Detailed setup instructions
├── infra/
│   └── terraform/
│       ├── provider.tf         # OCI provider config
│       ├── network.tf          # VCN, subnets, gateways
│       ├── compute.tf          # VM1, VM2, VM3 definitions
│       ├── outputs.tf          # VM IPs and resource IDs
│       ├── variables.tf        # Input variables
│       └── terraform.tfvars    # Your specific values (gitignored)
├── config/
│   └── ansible/
│       ├── inventory/
│       │   └── hosts.yml       # VM inventory
│       ├── playbooks/
│       │   ├── base-config.yml # OS hardening, packages
│       │   └── deploy-app.yml  # App deployment
│       └── roles/
│           ├── common/         # Base system config
│           ├── nginx/          # Web server setup
│           └── app/            # Application deployment
├── app/
│   ├── app.py                  # Demo Flask app
│   ├── requirements.txt        # Python dependencies
│   └── static/
│       └── index.html          # Simple homepage
├── .octopus/
│   └── deployment-process.md   # Octopus deployment steps
└── .github/
    └── workflows/
        └── ci.yml              # GitHub Actions workflow
```

---

## 🎯 Success Criteria

- [x] **Phase 1:** Can provision OCI network + VM1 with Terraform
- [ ] **Phase 2:** VM1 has Terraform, Ansible, Git installed
- [ ] **Phase 3:** Can provision VM2 from VM1 using Terraform
- [ ] **Phase 4:** Can configure VM2 with Ansible and deploy app
- [ ] **Phase 5:** Octopus can orchestrate full deployment
- [ ] **Phase 6:** GitHub push triggers automated deployment

---

## 🚀 Quick Start (Tonight)

```bash
# 1. Clone this repo on your Windows machine
cd C:\code
git clone https://github.com/ly2xxx/oci-devops-lab.git
cd oci-devops-lab

# 2. Configure OCI credentials
# Edit infra/terraform/terraform.tfvars with your OCI details

# 3. Initialize Terraform
cd infra\terraform
terraform init
terraform plan

# 4. Create infrastructure
terraform apply

# 5. SSH to VM1
ssh -i C:\Users\vl\.ssh\id_rsa opc@<VM1_PUBLIC_IP>

# 6. Continue with Phase 2 steps on VM1
```

---

## 📚 Prerequisites

### Software Needed
- [x] Terraform CLI (install: `choco install terraform`)
- [x] Git
- [ ] OCI CLI (optional but helpful)
- [ ] SSH client

### OCI Resources
- [ ] OCI Account (Always Free tier)
- [ ] API key pair created
- [ ] VCN quota available (1 VCN for free tier)
- [ ] Compute quota (2 Always Free VMs)

### Accounts
- [ ] GitHub account (for repo hosting)
- [ ] Octopus Cloud account (free tier)

---

## 🛠️ Troubleshooting

**Terraform "Authentication failed"**
- Check `~/.oci/config` has correct OCIDs
- Verify API key fingerprint matches OCI console
- Ensure private key has correct permissions (600)

**Ansible "Host unreachable"**
- Check security list allows SSH from VM1 to VM2
- Verify VM2 private IP in inventory
- Test SSH manually: `ssh opc@<VM2_IP>`

**Octopus Tentacle won't register**
- Check firewall allows outbound 443
- Verify Octopus Cloud instance URL
- Check API key is correct

---

## 📝 Learning Objectives

By completing this lab, you'll gain hands-on experience with:

✅ **Terraform:** IaC for cloud provisioning  
✅ **Ansible:** Configuration management and app deployment  
✅ **Octopus Deploy:** Release orchestration and environment promotion  
✅ **OCI:** Oracle Cloud Infrastructure  
✅ **CI/CD:** End-to-end automation pipeline  
✅ **GitOps:** Infrastructure and config as code  

---

**Next Step:** Follow `SETUP_GUIDE.md` for detailed Phase 1 instructions.
