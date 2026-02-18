# DevOps Lab - Terraform + Ansible + Octopus Deploy

**Platform:** Vagrant + VirtualBox (Local VMs)  
**Updated:** 2026-02-18  
**Learning Focus:** Infrastructure as Code, Configuration Management, Deployment Automation

---

## 🎯 What This Project Teaches

Learn production DevOps practices using local VMs (fast, free, no cloud account needed):

1. **Infrastructure as Code** - Vagrant + Terraform
2. **Configuration Management** - Ansible playbooks
3. **Deployment Automation** - Octopus Deploy
4. **Real-World Architecture** - Multi-VM setup with control node pattern

---

## 🚀 Quick Start (30 minutes)

### Prerequisites

```powershell
# Install VirtualBox
winget install Oracle.VirtualBox

# Install Vagrant
winget install Hashicorp.Vagrant

# Install Git
winget install Git.Git
```

### Launch Lab Environment

```powershell
# Clone repo
cd C:\code
git clone https://github.com/YOUR_USERNAME/oci-devops-lab.git
cd oci-devops-lab

# Start VMs (downloads Oracle Linux 8 first time, ~700MB)
vagrant up

# Wait 10-15 minutes for provisioning

# SSH to control node
vagrant ssh vm1-control

# Inside VM1, verify installations
terraform --version  # Should show 1.7.5
ansible --version    # Should show 2.x
ping -c 3 192.168.56.11  # Test connectivity to VM2
```

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Complete step-by-step setup (45 min) |
| **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** | Architecture overview and roadmap |
| **[Vagrantfile](Vagrantfile)** | VM configuration (2x Oracle Linux 8) |
| **[archive/](archive/)** | Original OCI cloud setup (deprecated) |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│     Your Windows Laptop                 │
│                                          │
│  ┌────────────────────────────────────┐ │
│  │  VM1 - Control Node                │ │
│  │  IP: 192.168.56.10                 │ │
│  │  RAM: 2GB, CPU: 2 cores            │ │
│  │  ────────────────────────────      │ │
│  │  • Terraform (Vagrant provider)    │ │
│  │  • Ansible                         │ │
│  │  • Git, Python3                    │ │
│  │  • Workspace: ~/workspace          │ │
│  └────────────────────────────────────┘ │
│                    │                     │
│                    │ Ansible over SSH    │
│                    ▼                     │
│  ┌────────────────────────────────────┐ │
│  │  VM2 - App Server                  │ │
│  │  IP: 192.168.56.11                 │ │
│  │  RAM: 2GB, CPU: 2 cores            │ │
│  │  ────────────────────────────      │ │
│  │  • Nginx (reverse proxy)           │ │
│  │  • Flask Demo App                  │ │
│  │  • Python3, Systemd services       │ │
│  │  • Managed by Ansible from VM1     │ │
│  └────────────────────────────────────┘ │
│                    │                     │
└────────────────────┼─────────────────────┘
                     │ Port Forwarding
                     ▼
            Your Browser: http://localhost:5000
```

---

## 📋 Learning Phases

### ✅ Phase 1: Infrastructure Provisioning (DONE)
- [x] Vagrantfile defines 2 VMs
- [x] VirtualBox provider configuration
- [x] Automated OS provisioning
- [x] Network setup (private network)

### ✅ Phase 2: Configuration Management (DONE)
- [x] Ansible inventory setup
- [x] Base configuration playbook
- [x] Flask app deployment playbook
- [x] Nginx reverse proxy setup

### 🔄 Phase 3: Octopus Deploy Integration (IN PROGRESS)
- [ ] Sign up for Octopus Cloud
- [ ] Install Tentacles on VMs
- [ ] Create deployment project
- [ ] Automate Flask deployment

### 📋 Phase 4: Advanced Terraform (PLANNED)
- [ ] Terraform Vagrant provider
- [ ] Infrastructure modules
- [ ] State management
- [ ] Variable-driven deployments

### 📋 Phase 5: CI/CD Pipeline (PLANNED)
- [ ] GitHub Actions workflow
- [ ] Automated testing
- [ ] Blue-green deployments
- [ ] Rollback procedures

---

## 🛠️ Common Tasks

### VM Management

```powershell
# Start VMs
vagrant up

# Stop VMs (preserves state)
vagrant halt

# Restart VMs
vagrant reload

# Destroy VMs (clean slate)
vagrant destroy -f

# SSH to VMs
vagrant ssh vm1-control
vagrant ssh vm2-app

# Check status
vagrant status
```

### Ansible (from VM1)

```bash
# SSH to VM1 first
vagrant ssh vm1-control

# Test connectivity
ansible all -m ping

# Run base configuration
cd ~/workspace/ansible
ansible-playbook playbooks/base-config.yml

# Deploy Flask app
ansible-playbook playbooks/deploy-app.yml

# Ad-hoc commands
ansible app_servers -m shell -a "systemctl status flask-app"
```

### Access Flask App

**From your browser:** http://localhost:5000

**From VM1 SSH:**
```bash
curl http://192.168.56.11
```

---

## 🎓 What You Learn

### Infrastructure as Code
- Declarative VM configuration (Vagrantfile)
- Reproducible environments
- Version-controlled infrastructure
- Provisioning automation

### Configuration Management
- Idempotent playbooks (run multiple times safely)
- Role-based organization
- Template-driven configs
- State management

### Deployment Automation
- Service orchestration (systemd)
- Reverse proxy setup (Nginx)
- Multi-tier applications
- Health checks and monitoring

### DevOps Best Practices
- Control node pattern (bastion/jump server)
- Private network communication
- Firewall configuration
- SSH key management

---

## 💡 Why Vagrant Instead of Cloud?

| Aspect | Vagrant (Local) | OCI Free Tier | Paid Cloud |
|--------|-----------------|---------------|------------|
| **Cost** | $0 | $0 | $10-50/month |
| **RAM/VM** | 2-4GB | 1GB | 2-8GB |
| **Setup Time** | 10 min | 30+ min | 5 min |
| **Install Speed** | ⚡ Fast | 🐌 Very slow | ⚡ Fast |
| **Iteration** | Instant | Slow | Fast |
| **Learning** | ✅ Best | ⚠️ Frustrating | ✅ Good |
| **Migration** | Easy → Cloud | N/A | N/A |

**Bottom line:** Master DevOps locally first, then apply to cloud. Same Ansible playbooks work everywhere!

---

## 🐛 Troubleshooting

### VM Won't Start

```powershell
# Check VirtualBox is running
& "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"

# Enable VT-x in BIOS if needed
systeminfo | findstr /i "hyper"

# Re-provision
vagrant destroy -f
vagrant up
```

### Ansible Connection Failed

```bash
# From VM1

# Test SSH manually
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.11

# Check network
ping -c 3 192.168.56.11

# Verbose debugging
ansible all -m ping -vvv
```

### Flask App Not Accessible

```bash
# SSH to VM2 directly
vagrant ssh vm2-app

# Check service status
sudo systemctl status flask-app
sudo systemctl status nginx

# Check firewall
sudo firewall-cmd --list-services

# Test locally
curl http://localhost:5000
```

---

## 🔄 Migration to Cloud

**When you're ready for cloud deployment:**

1. **OCI (Free Forever):** See `archive/terraform/` for configs
2. **AWS:** Modify playbooks for Amazon Linux 2
3. **Azure:** Use Azure Resource Manager + same playbooks
4. **DigitalOcean:** Simplest cloud migration ($200 credit)

**Your Ansible playbooks are cloud-agnostic!** Just update inventory IPs.

---

## 📞 Resources

**Documentation:**
- [Vagrant Docs](https://www.vagrantup.com/docs)
- [Ansible Docs](https://docs.ansible.com)
- [Octopus Deploy](https://octopus.com/docs)

**This Project:**
- Setup Guide: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- Architecture: [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)
- OCI Archive: [archive/README.md](archive/README.md)

**Community:**
- Vagrant: https://discuss.hashicorp.com/c/vagrant
- Ansible: https://www.reddit.com/r/ansible
- DevOps: https://www.reddit.com/r/devops

---

## 🎯 Success Metrics

- [ ] Both VMs running (`vagrant status`)
- [ ] Ansible can ping both VMs
- [ ] Base config applied successfully
- [ ] Flask app deployed and accessible
- [ ] Can access http://localhost:5000 from browser
- [ ] Understand each Ansible task
- [ ] Can destroy/rebuild environment in <10 min

---

## 🚀 Next Steps

**Today:**
1. Complete Phase 1-2 (VMs + Ansible)
2. Access Flask app in browser
3. Modify playbook and re-deploy

**This Week:**
4. Set up Octopus Deploy
5. Automate deployment pipeline
6. Add monitoring/logging

**This Month:**
7. Learn Terraform Vagrant provider
8. Create custom Ansible roles
9. Deploy to real cloud (DigitalOcean/OCI)

---

## 📝 Change Log

**2026-02-18:**
- Migrated from OCI to Vagrant (performance issues)
- Created comprehensive Vagrantfile
- Updated all documentation
- Archived OCI configs in `archive/`

**2026-02-17:**
- Initial project creation
- OCI Terraform configs
- Ansible playbooks

---

**Ready to learn DevOps the right way?** 🚀

```powershell
cd C:\code\oci-devops-lab
vagrant up
vagrant ssh vm1-control
```

**Happy learning!** 🎓
