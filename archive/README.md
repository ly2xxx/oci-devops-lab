# OCI Archive - Original Cloud-Based Setup

**Date Archived:** 2026-02-18  
**Reason:** Performance issues with OCI Free Tier (1GB RAM too limited for package installs)  
**New Approach:** Vagrant + VirtualBox (local VMs with 2GB RAM each)

---

## 📁 What's Here

This folder contains the original OCI (Oracle Cloud Infrastructure) based setup:

| File/Folder | Description |
|-------------|-------------|
| **SETUP_GUIDE_OCI.md** | Original step-by-step OCI setup guide |
| **QUICKSTART_OCI.md** | Original 30-minute OCI quickstart |
| **terraform/** | Terraform configs for OCI infrastructure |
| **terraform/TROUBLESHOOT.md** | OCI-specific troubleshooting |
| **terraform/CLOUD_INIT_OOM_FIX.md** | Documentation of OOM issue with 1GB RAM |

---

## ⚠️ Known Issues with OCI Free Tier

### 1. Out of Memory (OOM) During Cloud-Init
- **Problem:** `yum update -y` gets killed by OOM on 1GB RAM VMs
- **Impact:** Cloud-init fails, packages don't install
- **Workaround:** Manual installation or remove system update from cloud-init

### 2. Slow Package Installation
- **Problem:** Even basic `yum install` takes 15+ minutes
- **Cause:** Limited RAM + network latency + Oracle Linux repos
- **Impact:** Poor learning experience, frustrating delays

### 3. Availability Domain Capacity
- **Problem:** AD-1 often full in popular regions (uk-london-1)
- **Workaround:** Try AD-2 or AD-3

---

## ✅ What Worked

- ✅ Terraform configs are solid (VCN, subnets, security lists)
- ✅ Networking architecture is correct
- ✅ Ansible inventory structure is good
- ✅ Always Free tier is truly free (2 VMs, 100GB storage)

---

## 🔄 Migration Path

### If You Want to Use OCI Later

**After mastering locally with Vagrant:**

1. **Use the Terraform configs here** to provision OCI infrastructure
2. **Update Ansible inventory** with OCI public IPs:
   ```yaml
   vm1:
     ansible_host: <OCI_VM1_PUBLIC_IP>
   vm2:
     ansible_host: <OCI_VM2_PRIVATE_IP>  # From VM1 via VCN
   ```
3. **Skip cloud-init** - manually install packages or use pre-baked images
4. **Run same Ansible playbooks** from VM1 to VM2

---

## 📚 OCI Resources (Still Valid)

**Terraform Docs:**
- Provider: https://registry.terraform.io/providers/oracle/oci/latest/docs
- Always Free: https://www.oracle.com/cloud/free/

**Fixes Applied:**
- ✅ Removed `yum update -y` from cloud-init (CLOUD_INIT_OOM_FIX.md)
- ✅ Changed to AD-3 for capacity (terraform.tfvars)
- ✅ Created manual setup scripts (setup-vm1-manual.sh)

---

## 🎓 Lessons Learned

1. **Free != Good for Learning** - Vagrant local VMs are better starting point
2. **1GB RAM is borderline unusable** for modern Linux package management
3. **Cloud-init should be minimal** on resource-constrained VMs
4. **Test locally first** - faster iteration, easier debugging
5. **Migrate to cloud later** - once workflow is solid

---

## 💰 Cost Comparison

| Platform | Cost/Month | RAM/VM | Speed | Setup Time |
|----------|------------|--------|-------|------------|
| **OCI Free** | $0 | 1GB | 🐌 Slow | 30+ min |
| **Vagrant Local** | $0 | 2-4GB | ⚡ Fast | 10 min |
| **DigitalOcean** | $12 ($200 credit) | 2GB | ⚡⚡ Fast | 5 min |
| **Hetzner** | €8 | 2GB | ⚡⚡⚡ Fast | 5 min |

**Recommendation:** Use Vagrant for learning, OCI for long-term free hosting.

---

## 🚀 Current Project Status

**Active Setup:** Vagrant + VirtualBox (see parent folder)

**OCI Infrastructure:** Partially deployed (VMs running but not fully configured)

**To cleanup OCI VMs:**
```powershell
cd C:\code\oci-devops-lab\archive\terraform
terraform destroy -auto-approve
```

---

## 📞 Need Help with OCI?

If you still want to use OCI:

1. Read **TROUBLESHOOT.md** for common issues
2. Check **CLOUD_INIT_OOM_FIX.md** for memory solutions
3. Use **setup-vm1-manual.sh** for manual installs
4. Consider upgrading to paid tier (2GB+ RAM instances)

---

**Archived but not forgotten!** These configs work, they're just not optimal for learning due to performance constraints.

Return to: [../SETUP_GUIDE.md](../SETUP_GUIDE.md) for the Vagrant-based approach.
