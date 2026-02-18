# OCI DevOps Lab - Quick Start

**Goal:** Get infrastructure running in 30 minutes.

---

## Prerequisites Checklist

- [ ] OCI Account (Always Free tier)
- [ ] Terraform installed (`terraform version`)
- [ ] SSH key pair generated (`~/.ssh/id_rsa.pub`)
- [ ] OCI API key created in **PEM format** (not OpenSSH!)

---

## ⚠️ Important: OCI API Key Format

**OCI requires PEM format, not OpenSSH format!**

**Correct command:**
```bash
ssh-keygen -t rsa -b 4096 -m PEM -f ~/.oci/oci_api_key -N ""
mv ~/.oci/oci_api_key ~/.oci/oci_api_key.pem
```

**Verify:**
```bash
head -1 ~/.oci/oci_api_key.pem
# Should show: -----BEGIN PRIVATE KEY-----
# NOT: -----BEGIN OPENSSH PRIVATE KEY-----
```

---

## 5 Steps to Running Infrastructure

### 1. Configure OCI Credentials (5 min)

```powershell
cd C:\code\oci-devops-lab\infra\terraform

# Copy and edit config file
copy terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars

# Fill in:
# - tenancy_ocid
# - user_ocid
# - fingerprint
# - region
# - compartment_ocid
# - Use absolute paths: C:/Users/vl/.oci/oci_api_key.pem
```

**Important:** On Windows, use absolute paths with forward slashes:
```hcl
private_key_path = "C:/Users/vl/.oci/oci_api_key.pem"
ssh_public_key_path = "C:/Users/vl/.ssh/id_rsa.pub"
```

### 2. Initialize Terraform (2 min)

```powershell
terraform init
```

### 3. Preview Infrastructure (2 min)

```powershell
terraform plan

# Should show:
# - 1 VCN
# - 2 subnets
# - 1 internet gateway
# - 2 VMs (VM1, VM2)
```

### 4. Create Infrastructure (10 min)

```powershell
terraform apply

# Type 'yes'
# Wait ~5-10 minutes
```

### 5. Get Connection Info (1 min)

```powershell
# Get all outputs
terraform output

# Get SSH command
terraform output ssh_to_vm1

# Copy and run to connect
ssh -i C:\Users\vl\.ssh\id_rsa opc@<IP>
```

---

## What Gets Created?

| Resource | Type | Purpose |
|----------|------|---------|
| devops-lab-vcn | VCN | Network container |
| public-subnet | Subnet | For VM1 |
| private-subnet | Subnet | For VM2 |
| devops-lab-igw | Internet Gateway | Public access |
| vm1-control-node | Compute | Terraform + Ansible |
| vm2-app-server | Compute | Web app server |

**Cost:** $0 (Always Free tier)

---

## Next Steps

Once VMs are running:

1. **SSH to VM1:**
   ```bash
   ssh -i ~/.ssh/id_rsa opc@<VM1_IP>
   ```

2. **Clone repo on VM1:**
   ```bash
   git clone https://github.com/ly2xxx/oci-devops-lab.git
   cd oci-devops-lab
   ```

3. **Run Ansible:**
   ```bash
   cd config/ansible
   # Update inventory with VM IPs
   ansible-playbook -i inventory/hosts.yml playbooks/base-config.yml
   ansible-playbook -i inventory/hosts.yml playbooks/deploy-app.yml
   ```

4. **Access app:**
   - Browser: `http://<VM2_PUBLIC_IP>`

---

## Troubleshooting

**Terraform fails with "authentication error":**
- Check `terraform.tfvars` has correct OCIDs
- Verify API key fingerprint
- **Ensure private key is in PEM format** (not OpenSSH)
- Check key file permissions: `chmod 600 ~/.oci/oci_api_key.pem`

**How to check key format:**
```bash
head -1 ~/.oci/oci_api_key.pem
# PEM format: -----BEGIN PRIVATE KEY-----
# OpenSSH format: -----BEGIN OPENSSH PRIVATE KEY----- (WRONG!)
```

**VM won't start:**
- Check Always Free capacity in your region
- Try different availability domain (1, 2, or 3)

**Can't SSH to VM1:**
- Wait 2-3 minutes for cloud-init
- Check security list allows SSH from your IP
- Verify SSH key path is correct

---

**For detailed setup:** See `SETUP_GUIDE.md`
