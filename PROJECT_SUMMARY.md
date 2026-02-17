# OCI DevOps Lab - Project Summary

**Created:** 2026-02-17  
**Author:** Yang Li  
**Purpose:** Learn Terraform + Ansible + Octopus Deploy on OCI

---

## What This Project Does

Builds a complete DevOps pipeline on Oracle Cloud Infrastructure (OCI) using:
- **Terraform** for infrastructure provisioning
- **Ansible** for configuration management
- **Octopus Deploy** for deployment orchestration

---

## Architecture Overview

```
GitHub Repo
    ↓
Windows Machine (You)
    ↓ Terraform Apply
OCI Cloud
    ├── VM1 (Control Node)
    │   ├── Terraform CLI
    │   ├── Ansible
    │   └── Octopus Tentacle
    │
    └── VM2 (App Server)
        ├── Nginx
        ├── Flask Demo App
        └── Octopus Tentacle
```

---

## What You'll Learn

1. **Infrastructure as Code (Terraform)**
   - VCN, subnets, security lists
   - Compute instances (Always Free)
   - Output variables for automation

2. **Configuration Management (Ansible)**
   - Inventory management
   - Playbooks (base config, app deployment)
   - Idempotent operations

3. **Deployment Orchestration (Octopus)**
   - Environments & targets
   - Multi-step deployments
   - Integration with Terraform + Ansible

4. **Cloud Architecture (OCI)**
   - Networking (VCN, subnets, gateways)
   - Compute (Always Free tier)
   - Security (security lists, SSH keys)

---

## File Structure

```
oci-devops-lab/
├── README.md                 # Overview & phase-by-phase plan
├── SETUP_GUIDE.md           # Detailed step-by-step instructions
├── QUICKSTART.md            # Fast track (30 min)
├── PROJECT_SUMMARY.md       # This file
│
├── infra/terraform/         # Infrastructure as Code
│   ├── provider.tf          # OCI provider config
│   ├── variables.tf         # Input variables
│   ├── terraform.tfvars     # Your values (gitignored)
│   ├── network.tf           # VCN, subnets, gateways
│   ├── compute.tf           # VM1, VM2 definitions
│   ├── outputs.tf           # VM IPs, SSH commands
│   ├── cloud-init-vm1.sh    # VM1 bootstrap script
│   └── cloud-init-vm2.sh    # VM2 bootstrap script
│
├── config/ansible/          # Configuration Management
│   ├── ansible.cfg          # Ansible settings
│   ├── inventory/
│   │   └── hosts.yml        # VM inventory
│   ├── playbooks/
│   │   ├── test-connection.yml   # Connectivity test
│   │   ├── base-config.yml       # OS hardening
│   │   └── deploy-app.yml        # App deployment
│   └── roles/               # (Future: organized roles)
│
├── app/                     # Demo Application
│   ├── app.py               # Flask web app
│   └── requirements.txt     # Python dependencies
│
├── .octopus/                # Octopus Deploy Config
│   └── deployment-process.md     # Deployment steps
│
└── .github/workflows/       # (Future: CI/CD automation)
    └── ci.yml
```

---

## Implementation Phases

### ✅ Phase 1: Terraform Foundation
- Configure OCI credentials
- Create VCN and networking
- Provision VM1 (control node)

### ✅ Phase 2: Control Node Setup
- Install Terraform + Ansible on VM1
- Clone repo to VM1
- Configure OCI credentials

### ✅ Phase 3: App Server Provisioning
- Create VM2 with Terraform
- Configure networking & security
- Verify SSH access

### ✅ Phase 4: Ansible Configuration
- Update Ansible inventory
- Run base configuration playbook
- Deploy demo Flask app

### 🔄 Phase 5: Octopus Integration (In Progress)
- Set up Octopus Cloud
- Install Tentacles on VMs
- Create deployment project
- Configure deployment process

### 📋 Phase 6: CI/CD Automation (Planned)
- GitHub Actions workflow
- Auto-deploy on push to main
- Environment promotion (Dev → Test)

---

## Key Technologies

| Tech | Version | Purpose |
|------|---------|---------|
| Terraform | 1.7+ | Infrastructure provisioning |
| Ansible | 2.15+ | Configuration management |
| Octopus Deploy | Cloud | Deployment orchestration |
| OCI | Always Free | Cloud infrastructure |
| Oracle Linux | 8 | OS for VMs |
| Nginx | Latest | Web server / reverse proxy |
| Flask | 3.0+ | Demo web application |
| Python | 3.8+ | App runtime |

---

## Current Status

**Infrastructure:** ✅ Ready to deploy  
**Terraform Code:** ✅ Complete  
**Ansible Playbooks:** ✅ Complete  
**Demo App:** ✅ Complete  
**Octopus Integration:** 📋 Documentation ready

---

## Next Actions

### Tonight (Phase 1-4):
1. Configure `terraform.tfvars` with your OCI credentials
2. Run `terraform init && terraform apply`
3. SSH to VM1
4. Clone repo and run Ansible playbooks
5. Access demo app in browser

### Tomorrow (Phase 5-6):
1. Sign up for Octopus Cloud
2. Install Tentacles on VMs
3. Configure deployment process
4. Set up GitHub Actions (optional)

---

## Success Metrics

- [ ] VMs running on OCI (cost: $0)
- [ ] Can SSH to both VMs
- [ ] Ansible successfully configures VMs
- [ ] Demo app accessible via browser
- [ ] Octopus can deploy end-to-end
- [ ] GitHub push triggers auto-deploy

---

## Resources

**Documentation:**
- [Terraform OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Octopus Deploy Docs](https://octopus.com/docs)

**OCI Resources:**
- [Always Free Services](https://www.oracle.com/cloud/free/)
- [OCI Documentation](https://docs.oracle.com/en-us/iaas/Content/home.htm)

**This Project:**
- README.md - Overview
- SETUP_GUIDE.md - Step-by-step
- QUICKSTART.md - Fast track

---

## Troubleshooting Guide

**Problem:** Terraform authentication fails  
**Solution:** Check `terraform.tfvars` and API key fingerprint

**Problem:** VM won't start  
**Solution:** Check Always Free capacity, try different availability domain

**Problem:** Ansible can't connect to VM2  
**Solution:** Update security list to allow SSH from VCN, verify IPs in inventory

**Problem:** App not accessible  
**Solution:** Check firewall (`firewall-cmd --list-all`), verify Nginx/app services running

---

## Cost Breakdown

| Resource | Quantity | Cost |
|----------|----------|------|
| VCN | 1 | $0 (Always Free) |
| Compute VMs | 2x VM.Standard.E2.1.Micro | $0 (Always Free) |
| Block Storage | 100GB (50GB each) | $0 (Always Free) |
| Outbound Traffic | First 10TB/month | $0 (Always Free) |

**Total Monthly Cost:** $0 🎉

---

## Lessons Learned

*(Update as you progress)*

- OCI Always Free is generous (2 VMs, 100GB storage, 10TB egress)
- Terraform state should be in remote backend for teams
- Ansible playbooks should be idempotent (safe to re-run)
- Octopus Cloud simplifies deployment (no self-hosting)

---

## Future Enhancements

- [ ] Add VM3 for database (PostgreSQL)
- [ ] Implement Terraform remote state (OCI Object Storage)
- [ ] Create Ansible roles for better organization
- [ ] Add monitoring (Prometheus + Grafana)
- [ ] Implement blue-green deployments
- [ ] Add SSL/TLS with Let's Encrypt
- [ ] CI/CD with GitHub Actions
- [ ] Infrastructure testing (Terratest)

---

**Ready to start?** See `QUICKSTART.md` for fastest path, or `SETUP_GUIDE.md` for detailed instructions.

🚀 **Let's build something awesome!**
