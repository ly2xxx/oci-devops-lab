# DevOps Lab Setup Guide - Vagrant Edition

**Updated:** 2026-02-18 (Tested & Verified)  
**Platform:** Vagrant + VirtualBox (Local VMs)  
**Time to Complete:** 45-60 minutes  
**Cost:** $0 (runs on your laptop)

---

## 📋 Why Vagrant Instead of OCI?

**Performance:**
- ✅ **2GB RAM per VM** (vs OCI's 1GB)
- ✅ **Fast package installs** (no internet bottleneck)
- ✅ **Instant snapshots/rollback**
- ✅ **Full control over resources**

**Learning:**
- ✅ **Same Ansible playbooks** work locally and cloud
- ✅ **Practice without cloud costs/limits**
- ✅ **Faster iteration** (destroy/rebuild in minutes)

**Migration Path:**
- ✅ Master locally first → Move to OCI/AWS/Azure later
- ✅ Ansible playbooks are cloud-agnostic

---

## 🎯 What You'll Build

```
Your Windows Laptop
    ├── VM1 (Control Node) - 192.168.56.10
    │   ├── Terraform 1.7.5
    │   ├── Ansible 2.9+
    │   └── Workspace with playbooks
    │
    └── VM2 (App Server) - 192.168.56.11
        ├── Nginx (reverse proxy on port 80)
        ├── Flask Demo App (port 5000, internal)
        └── Managed by Ansible from VM1
```

**Access:**
- VM1 SSH: `vagrant ssh vm1-control`
- VM2 SSH: `vagrant ssh vm2-app`
- **Flask App:** http://localhost:8080 (from Windows browser)

---

## 📦 Phase 0: Prerequisites (15 minutes)

### Step 1: Install VirtualBox

**Windows (PowerShell as Administrator):**
```powershell
winget install Oracle.VirtualBox
```

**Or download manually:** https://www.virtualbox.org/wiki/Downloads

**Verify installation:**
```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" --version
```

---

### Step 2: Install Vagrant

**Windows (PowerShell as Administrator):**
```powershell
winget install Hashicorp.Vagrant
```

**Or download manually:** https://www.vagrantup.com/downloads

**After installation, RESTART PowerShell** (to reload PATH), then verify:
```powershell
vagrant --version
# Should show: Vagrant 2.4.x
```

---

### Step 3: Fix VirtualBox Host-Only Network (If Needed)

**Check if adapter exists:**
```powershell
cd "C:\Program Files\Oracle\VirtualBox"
.\VBoxManage.exe list hostonlyifs
```

**If empty or error, create it:**
```powershell
# Run as Administrator
cd C:\code\oci-devops-lab
.\force-fix-adapter.ps1

# Or manually:
cd "C:\Program Files\Oracle\VirtualBox"
.\VBoxManage.exe hostonlyif create
```

**Verify adapter created:**
```powershell
Get-NetAdapter | Where-Object {$_.Name -like "*VirtualBox*"}
# Should show: VirtualBox Host-Only Ethernet Adapter, Status: Up
```

---

## 🚀 Phase 1: Launch VMs (10-15 minutes)

### Step 1: Navigate to Project

```powershell
cd C:\code\oci-devops-lab
```

---

### Step 2: Start VMs

```powershell
# First time: Downloads Oracle Linux 8 box (~700MB) + provisions VMs
vagrant up

# This will:
# - Download base box (one-time, 5-10 min)
# - Import and create VM1 and VM2
# - Configure networking
# - Attempt provisioning (might fail due to SSH timeout - expected!)
```

**Expected output:**
```
==> vm1-control: Importing base box 'generic/oracle8'...
==> vm1-control: Booting VM...
==> vm1-control: Running provisioner: shell...
    vm1-control: === Provisioning VM1 (Control Node) ===
... (might timeout here - that's OK!)
```

**Note:** Provisioning might fail with "SSH connection unexpectedly closed" during `yum update`. This is **expected** - we'll fix it manually.

---

### Step 3: Verify VMs Are Running

```powershell
vagrant status

# Should show:
# vm1-control    running (virtualbox)
# vm2-app        running (virtualbox)
```

**If VM2 didn't start:**
```powershell
vagrant up vm2-app
```

---

### Step 4: Test Network Connectivity

```powershell
# Ping VM1
ping 192.168.56.10

# Ping VM2
ping 192.168.56.11

# Both should respond
```

---

## 🔧 Phase 2: Configure VM1 (Control Node) - 15 minutes

### Step 1: SSH to VM1

```powershell
vagrant ssh vm1-control
```

You're now inside VM1!

---

### Step 2: Check What Got Installed

```bash
# Check if provisioning completed
terraform --version  # Likely: command not found
ansible --version    # Likely: command not found
git --version        # Likely: command not found
```

**If commands not found**, provisioning failed (expected). Continue to Step 3.

---

### Step 3: Install Packages Manually

**Copy-paste this entire block:**

```bash
# Install essential packages (skip full yum update - too slow)
sudo yum install -y git wget curl vim unzip python3-pip

# Install Terraform
cd /tmp
wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip -o terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform
rm terraform_1.7.5_linux_amd64.zip

# Install Ansible
sudo pip3 install --upgrade pip
sudo pip3 install ansible

# Create workspace
mkdir -p ~/workspace

# Generate SSH key for Ansible
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
```

**This takes ~3-5 minutes.**

---

### Step 4: Verify Installations

```bash
terraform --version   # Should show: Terraform v1.7.5
ansible --version     # Should show: ansible 2.9.x (with Python 3.6 warning - ignore it)
git --version         # Should show: git 2.x
python3 --version     # Should show: Python 3.6.8
```

---

### Step 5: Test Connectivity to VM2

```bash
# Ping VM2
ping -c 3 192.168.56.11

# Should get 3 replies
```

---

## 📝 Phase 3: Set Up Ansible (10 minutes)

### Step 1: Create Ansible Directory Structure

```bash
cd ~/workspace
mkdir -p ansible/inventory
mkdir -p ansible/playbooks
cd ansible
```

---

### Step 2: Create ansible.cfg

```bash
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml
deprecation_warnings = False

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
```

---

### Step 3: Copy SSH Key to VM2

```bash
# Install sshpass (for password-based key copy)
sudo yum install -y sshpass

# Copy public key to VM2
sshpass -p vagrant ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.11
```

**Expected output:** "Number of key(s) added: 1"

---

### Step 4: Create Ansible Inventory

```bash
cat > inventory/hosts.yml << 'EOF'
all:
  children:
    control:
      hosts:
        vm1:
          ansible_host: 192.168.56.10
          ansible_connection: local
    
    app_servers:
      hosts:
        vm2:
          ansible_host: 192.168.56.11
          ansible_user: vagrant
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
```

---

### Step 5: Test Ansible Connectivity

```bash
ansible all -m ping
```

**Expected output:**
```yaml
vm1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
vm2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

✅ **If both show SUCCESS, Ansible is working!**

---

## 🎭 Phase 4: Create and Run Ansible Playbooks (15 minutes)

### Playbook 1: Base Configuration

```bash
cd ~/workspace/ansible

cat > playbooks/base-config.yml << 'EOF'
---
- name: Configure base system on all hosts
  hosts: all
  become: yes
  
  tasks:
    # Skip full system update - too resource intensive
    # Can be done manually later: sudo yum update -y
    
    - name: Install essential packages
      yum:
        name:
          - vim
          - git
          - wget
          - curl
          - net-tools
        state: present
    
    - name: Set timezone to Europe/London
      timezone:
        name: Europe/London
    
    - name: Ensure firewalld is running
      systemd:
        name: firewalld
        state: started
        enabled: yes
    
    - name: Configure SSH to allow key-based auth
      lineinfile:
        path: /etc/ssh/sshd_config
        regexp: '^#?PubkeyAuthentication'
        line: 'PubkeyAuthentication yes'
      notify: restart sshd
  
  handlers:
    - name: restart sshd
      systemd:
        name: sshd
        state: restarted
EOF
```

**Run the playbook:**
```bash
ansible-playbook playbooks/base-config.yml
```

**Expected output:**
```
PLAY RECAP
vm1    : ok=X    changed=X
vm2    : ok=X    changed=X
```

---

### Playbook 2: Deploy Flask App

```bash
cat > playbooks/deploy-app.yml << 'EOF'
---
- name: Deploy Flask demo app on VM2
  hosts: app_servers
  become: yes
  
  vars:
    app_dir: /opt/flask-app
    app_user: flask
  
  tasks:
    - name: Install Python and dependencies
      yum:
        name:
          - python3
          - python3-pip
          - nginx
        state: present
    
    - name: Create app user
      user:
        name: "{{ app_user }}"
        system: yes
        shell: /bin/bash
        home: "{{ app_dir }}"
        createhome: yes
    
    - name: Create app directory
      file:
        path: "{{ app_dir }}"
        state: directory
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: '0755'
    
    - name: Copy Flask app code
      copy:
        content: |
          from flask import Flask
          import socket
          
          app = Flask(__name__)
          
          @app.route('/')
          def home():
              hostname = socket.gethostname()
              return f"""
              <html>
                <head><title>DevOps Lab Demo</title></head>
                <body style="font-family: Arial; padding: 50px; background: #f0f0f0;">
                  <h1 style="color: #333;">🚀 DevOps Lab - Flask Demo</h1>
                  <p><strong>Hostname:</strong> {hostname}</p>
                  <p><strong>Server IP:</strong> 192.168.56.11</p>
                  <p><strong>Deployed with:</strong> Vagrant + Ansible</p>
                  <hr>
                  <p>✅ VM provisioning: Vagrant</p>
                  <p>✅ Configuration: Ansible</p>
                  <p>✅ Deployment: Automated playbook</p>
                </body>
              </html>
              """
          
          if __name__ == '__main__':
              app.run(host='0.0.0.0', port=5000)
        dest: "{{ app_dir }}/app.py"
        owner: "{{ app_user }}"
        group: "{{ app_user }}"
        mode: '0644'
    
    - name: Install Flask
      pip:
        name: flask
        executable: pip3
    
    - name: Create systemd service for Flask app
      copy:
        content: |
          [Unit]
          Description=Flask Demo App
          After=network.target
          
          [Service]
          User={{ app_user }}
          WorkingDirectory={{ app_dir }}
          ExecStart=/usr/bin/python3 {{ app_dir }}/app.py
          Restart=always
          
          [Install]
          WantedBy=multi-user.target
        dest: /etc/systemd/system/flask-app.service
        mode: '0644'
    
    - name: Reload systemd
      systemd:
        daemon_reload: yes
    
    - name: Start Flask app service
      systemd:
        name: flask-app
        state: started
        enabled: yes
    
    - name: Create clean Nginx config
      copy:
        content: |
          user nginx;
          worker_processes auto;
          error_log /var/log/nginx/error.log;
          pid /run/nginx.pid;
          
          events {
              worker_connections 1024;
          }
          
          http {
              include /etc/nginx/mime.types;
              default_type application/octet-stream;
              
              access_log /var/log/nginx/access.log;
              
              sendfile on;
              keepalive_timeout 65;
              
              include /etc/nginx/conf.d/*.conf;
          }
        dest: /etc/nginx/nginx.conf
        mode: '0644'
      notify: restart nginx
    
    - name: Configure Nginx as reverse proxy
      copy:
        content: |
          server {
              listen 80;
              server_name _;
              
              location / {
                  proxy_pass http://127.0.0.1:5000;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
              }
          }
        dest: /etc/nginx/conf.d/flask-app.conf
        mode: '0644'
      notify: restart nginx
    
    - name: Configure firewall for HTTP
      firewalld:
        service: "{{ item }}"
        permanent: yes
        state: enabled
        immediate: yes
      loop:
        - http
        - https
    
    - name: Allow Nginx to connect to Flask (SELinux)
      seboolean:
        name: httpd_can_network_connect
        state: yes
        persistent: yes
    
    - name: Start and enable Nginx
      systemd:
        name: nginx
        state: started
        enabled: yes
  
  handlers:
    - name: restart nginx
      systemd:
        name: nginx
        state: restarted
EOF
```

**Run the playbook:**
```bash
ansible-playbook playbooks/deploy-app.yml
```

**Expected output:**
```
PLAY RECAP
vm2    : ok=14   changed=10   unreachable=0   failed=0
```

---

## 🌐 Phase 5: Test the Application (5 minutes)

### From VM1 (via SSH):

```bash
# Test Flask app via Nginx
curl http://192.168.56.11

# Should see HTML with "🚀 DevOps Lab - Flask Demo"
```

---

### From Your Windows Browser:

**Open:** http://localhost:8080

**You should see:**
```
🚀 DevOps Lab - Flask Demo

Hostname: vm2-app
Server IP: 192.168.56.11
Deployed with: Vagrant + Ansible

✅ VM provisioning: Vagrant
✅ Configuration: Ansible
✅ Deployment: Automated playbook
```

✅ **Success!** Your DevOps lab is fully operational!

---

## 🎓 What You've Accomplished

- ✅ **Infrastructure as Code:** Vagrantfile defines VM resources
- ✅ **VM Provisioning:** 2 Oracle Linux 8 VMs with 2GB RAM each
- ✅ **Configuration Management:** Ansible playbooks configure VMs
- ✅ **Application Deployment:** Flask app deployed automatically
- ✅ **Service Management:** Systemd services, Nginx reverse proxy
- ✅ **Networking:** Private network + port forwarding
- ✅ **Security:** Firewall rules, SELinux configuration

---

## 🔧 Common Commands

### Vagrant Management (from Windows)

```powershell
# Start VMs
vagrant up

# Stop VMs (preserves state)
vagrant halt

# Restart VMs
vagrant reload

# Destroy VMs (complete cleanup)
vagrant destroy -f

# SSH to VMs
vagrant ssh vm1-control
vagrant ssh vm2-app

# Check VM status
vagrant status

# View SSH config
vagrant ssh-config
```

### Ansible (from VM1)

```bash
# Ping all hosts
ansible all -m ping

# Run ad-hoc command
ansible app_servers -m shell -a "systemctl status flask-app"

# Run playbook
ansible-playbook playbooks/deploy-app.yml

# Run playbook (check mode, no changes)
ansible-playbook playbooks/deploy-app.yml --check

# Run playbook (verbose)
ansible-playbook playbooks/deploy-app.yml -vvv
```

---

## 🐛 Troubleshooting

### VM Won't Start

```powershell
# Check VirtualBox GUI
& "C:\Program Files\Oracle\VirtualBox\VirtualBox.exe"

# Check logs
vagrant up --debug

# Force recreate host-only adapter
cd C:\code\oci-devops-lab
.\force-fix-adapter.ps1

# Destroy and retry
vagrant destroy -f
vagrant up
```

---

### Ansible Can't Connect to VM2

```bash
# From VM1

# Test SSH manually
ssh vagrant@192.168.56.11

# Re-copy SSH key
sshpass -p vagrant ssh-copy-id vagrant@192.168.56.11

# Check inventory
cat ~/workspace/ansible/inventory/hosts.yml

# Verbose Ansible ping
ansible all -m ping -vvv
```

---

### Flask App Not Accessible

```bash
# From VM1

# Check services on VM2
ansible app_servers -m shell -a "systemctl status flask-app"
ansible app_servers -m shell -a "systemctl status nginx"

# Check firewall
ansible app_servers -m shell -a "firewall-cmd --list-services"

# Check SELinux (502 errors)
ansible app_servers -m shell -a "getsebool httpd_can_network_connect"

# If "off", enable it
ansible app_servers -m shell -a "setsebool -P httpd_can_network_connect 1" --become

# Test locally on VM2
vagrant ssh vm2-app
curl http://localhost
```

---

### Port 8080 Not Working from Windows

```powershell
# Check if port 8080 is in use
netstat -ano | findstr :8080

# Check Vagrantfile port forwarding
cat Vagrantfile | findstr "forwarded_port"

# Should show:
# vm2.vm.network "forwarded_port", guest: 80, host: 8080

# If port conflict, change in Vagrantfile:
# vm2.vm.network "forwarded_port", guest: 80, host: 8081

# Then reload
vagrant reload vm2-app
```

---

### Provisioning Keeps Failing

**Expected:** Provisioning fails due to `yum update -y` timeout. This is normal.

**Solution:** Manual installation (covered in Phase 2, Step 3).

**Permanent fix (already applied):** Vagrantfile has been updated to skip `yum update -y`.

---

## 📚 Next Steps

### Phase 6: Octopus Deploy Integration (Optional)

1. Sign up for Octopus Cloud (free trial): https://octopus.com/start
2. Install Tentacle on VMs
3. Create deployment project
4. Automate Flask app deployment via Octopus

### Phase 7: Advanced Terraform (Optional)

Learn to provision Vagrant VMs with Terraform:

```hcl
# main.tf
terraform {
  required_providers {
    vagrant = {
      source = "bmatcuk/vagrant"
      version = "~> 4.0"
    }
  }
}

resource "vagrant_vm" "vm1" {
  name = "vm1-control"
  # ... configuration
}
```

### Phase 8: Migrate to Cloud (When Ready)

Once comfortable locally:
- Use same Ansible playbooks on OCI/AWS/Azure
- Update inventory with cloud IPs
- Practice cloud-specific features (load balancers, auto-scaling)

---

## 💡 Pro Tips

**Snapshot VMs before major changes:**
```bash
# In VirtualBox GUI
# Right-click VM → Snapshots → Take snapshot
# Or via command:
VBoxManage snapshot "devops-lab-vm1-control" take "before-change"
```

**Faster rebuilds:**
```powershell
# Destroy and recreate in one command
vagrant destroy -f && vagrant up
```

**Share code with VMs:**
```ruby
# Uncomment in Vagrantfile:
config.vm.synced_folder ".", "/vagrant"
```
Then your Windows files appear at `/vagrant` in VMs!

**Fix Python 3.6 deprecation warning:**
Oracle Linux 8 ships with Python 3.6. The Ansible warning is cosmetic - everything works fine. To suppress:
```bash
echo "deprecation_warnings = False" >> ~/workspace/ansible/ansible.cfg
```

---

## 📞 Support

**Issues?**
- Check troubleshooting section above
- Review `archive/` folder for OCI-specific issues (similar problems, different platform)
- Vagrant docs: https://www.vagrantup.com/docs
- Ansible docs: https://docs.ansible.com
- VirtualBox manual: https://www.virtualbox.org/manual

**Project Files:**
- README.md - Project overview
- PROJECT_SUMMARY.md - Architecture details
- MIGRATION_SUMMARY.md - Why we moved from OCI to Vagrant
- archive/ - Original OCI setup (preserved for reference)

---

## ✅ Success Checklist

- [ ] VirtualBox installed and host-only adapter working
- [ ] Vagrant installed and PATH updated
- [ ] Both VMs running (`vagrant status` shows both "running")
- [ ] Can SSH to VM1 and VM2
- [ ] Terraform and Ansible installed on VM1
- [ ] Ansible can ping both VMs successfully
- [ ] Base config playbook completed without errors
- [ ] Deploy app playbook completed without errors
- [ ] Flask app accessible from VM1: `curl http://192.168.56.11`
- [ ] Flask app accessible from Windows browser: http://localhost:8080

**If all checked:** Congratulations! 🎉 You've mastered the DevOps lab setup!

---

**Ready to learn DevOps the right way!** 🚀

**Questions? Stuck?** Review the troubleshooting section or check archive/ for additional insights.
