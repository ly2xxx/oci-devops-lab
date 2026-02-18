# DevOps Lab Setup Guide - Vagrant Edition

**Updated:** 2026-02-18  
**Platform:** Vagrant + VirtualBox (Local VMs)  
**Time to Complete:** 30-45 minutes  
**Cost:** $0 (runs on your laptop)

---

## 📋 Why Vagrant Instead of OCI?

**Performance:**
- ✅ **2GB RAM per VM** (vs OCI's 1GB)
- ✅ **Fast package installs** (no internet bottleneck)
- ✅ **Instant snapshots/rollback**
- ✅ **Full control over resources**

**Learning:**
- ✅ **Learn Terraform Vagrant provider** (still Infrastructure as Code!)
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
    │   ├── Terraform (Vagrant provider)
    │   ├── Ansible
    │   └── Workspace
    │
    └── VM2 (App Server) - 192.168.56.11
        ├── Nginx (reverse proxy)
        ├── Flask Demo App
        └── Managed by Ansible
```

**Access:**
- VM1: `vagrant ssh vm1-control`
- VM2: `vagrant ssh vm2-app`
- Flask App: http://localhost:5000 (from your browser)

---

## 📦 Prerequisites

### 1. Install VirtualBox

**Windows (PowerShell):**
```powershell
winget install Oracle.VirtualBox
```

**Or download manually:**
https://www.virtualbox.org/wiki/Downloads

**Verify:**
```powershell
& "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" --version
```

---

### 2. Install Vagrant

**Windows (PowerShell):**
```powershell
winget install Hashicorp.Vagrant
```

**Or download manually:**
https://www.vagrantup.com/downloads

**Verify:**
```powershell
vagrant --version
# Should show: Vagrant 2.4.x
```

---

### 3. Enable Virtualization in BIOS

**Check if enabled:**
```powershell
systeminfo | findstr /i "hyper"
```

**If disabled:**
- Reboot → Enter BIOS (F2/Del/F10)
- Enable VT-x (Intel) or AMD-V (AMD)
- Save and reboot

---

### 4. Install Git (if not already)

```powershell
winget install Git.Git
```

---

## 🚀 Phase 1: Launch VMs (10 minutes)

### Step 1: Navigate to Project

```powershell
cd C:\code\oci-devops-lab
```

### Step 2: Start VMs

```powershell
# Download Oracle Linux 8 box (first time only, ~700MB)
# Then create and provision both VMs
vagrant up

# This will:
# - Download the base box (5-10 min, one-time)
# - Create VM1 and VM2
# - Install Terraform + Ansible on VM1
# - Install basic tools on VM2
# - Configure networking
```

**Output you'll see:**
```
==> vm1-control: Importing base box 'generic/oracle8'...
==> vm1-control: Forwarding ports...
==> vm1-control: Running provisioner: shell...
=== Provisioning VM1 (Control Node) ===
Installing Terraform...
Installing Ansible...
VM1 provisioning complete!
Terraform: 1.7.5
Ansible: 2.x

==> vm2-app: Importing base box 'generic/oracle8'...
==> vm2-app: Running provisioner: shell...
=== Provisioning VM2 (App Server) ===
VM2 provisioning complete!
```

### Step 3: Verify VMs Are Running

```powershell
# Check status
vagrant status

# Should show:
# vm1-control    running (virtualbox)
# vm2-app        running (virtualbox)
```

---

## 🔧 Phase 2: Configure Control Node (15 minutes)

### Step 1: SSH to VM1

```powershell
vagrant ssh vm1-control
```

**You're now inside VM1!**

### Step 2: Verify Installations

```bash
# Check installed tools
terraform --version
ansible --version
git --version
python3 --version

#if not installed, run the following command:
sudo yum install -y git wget curl vim unzip python3-pip && cd /tmp && wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip && unzip -o terraform_1.7.5_linux_amd64.zip && sudo mv terraform /usr/local/bin/ && sudo chmod +x /usr/local/bin/terraform && rm terraform_1.7.5_linux_amd64.zip && sudo pip3 install --upgrade pip && sudo pip3 install ansible && mkdir -p ~/workspace && echo "✅ Setup complete!" && terraform --version && ansible --version && git --version

# Check network connectivity to VM2
ping -c 3 192.168.56.11
```

### Step 3: Set Up Ansible Inventory

```bash
# Create Ansible directory structure
mkdir -p ~/workspace/ansible/inventory
cd ~/workspace/ansible

# Create inventory file
# Generate SSH key if not already done
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
fi

# Copy public key to VM2
ssh-copy-id -o StrictHostKeyChecking=no vagrant@192.168.56.11
# Password: vagrant

# Update inventory to use the correct key
cat > ~/workspace/ansible/inventory/hosts.yml << 'EOF'
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

# Create ansible.cfg
cat > ansible.cfg << 'EOF'
[defaults]
inventory = inventory/hosts.yml
host_key_checking = False
retry_files_enabled = False
stdout_callback = yaml

[privilege_escalation]
become = True
become_method = sudo
become_user = root
become_ask_pass = False
EOF
```

### Step 4: Test Ansible Connectivity

```bash
# Ping all hosts
ansible all -m ping

# Expected output:
# vm1 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
# vm2 | SUCCESS => {
#     "changed": false,
#     "ping": "pong"
# }
```

**If VM2 fails:**
```bash
# Add Vagrant's SSH key to known hosts manually
ssh-keyscan -H 192.168.56.11 >> ~/.ssh/known_hosts

# Or SSH once manually to accept key
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.11
# Password: vagrant (if prompted)
# Type 'exit' to return to VM1
```

---

## 📝 Phase 3: Create Ansible Playbooks (10 minutes)

### Playbook 1: Base Configuration

```bash
cd ~/workspace/ansible

# Create playbooks directory
mkdir -p playbooks

# Create base config playbook
cat > playbooks/base-config.yml << 'EOF'
---
- name: Configure base system on all hosts
  hosts: all
  become: yes
  
  tasks:
      # Skip system update - too resource intensive for 2GB VMs
    #- name: Ensure system packages are up to date
    #  yum:
    #    name: '*'
    #    state: latest
    #    update_cache: yes
    
    - name: Install essential packages
      yum:
        name:
          - vim
          - git
          - wget
          - curl
          - net-tools
         # - htop
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
                  <p>✅ Deployment: Octopus (coming soon)</p>
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
    
    - name: Remove default Nginx config
      file:
        path: /etc/nginx/conf.d/default.conf
        state: absent
    
    - name: Configure firewall for HTTP
      firewalld:
        service: "{{ item }}"
        permanent: yes
        state: enabled
        immediate: yes
      loop:
        - http
        - https
    
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

---

## ▶️ Phase 4: Run Playbooks (5 minutes)

### Run Base Configuration

```bash
cd ~/workspace/ansible

# Apply base config to all VMs
ansible-playbook playbooks/base-config.yml

# Expected output:
# PLAY RECAP
# vm1    : ok=X    changed=X
# vm2    : ok=X    changed=X
```

### Deploy Flask App

```bash
# Deploy app to VM2
ansible-playbook playbooks/deploy-app.yml

# Expected output:
# PLAY RECAP
# vm2    : ok=X    changed=X
```

---

## 🌐 Phase 5: Test the Application

### From VM1 (inside vagrant ssh):

```bash
# Test Flask app directly
curl http://192.168.56.11:5000

# Test via Nginx
curl http://192.168.56.11
```

### From Your Windows Browser:

**Open:** http://localhost:5000

You should see:
```
🚀 DevOps Lab - Flask Demo
Hostname: vm2-app
Server IP: 192.168.56.11
Deployed with: Vagrant + Ansible

✅ VM provisioning: Vagrant
✅ Configuration: Ansible
✅ Deployment: Octopus (coming soon)
```

---

## 🎓 What You've Accomplished

- ✅ **Infrastructure as Code:** Vagrantfile defines VM resources
- ✅ **Configuration Management:** Ansible playbooks configure VMs
- ✅ **Application Deployment:** Flask app deployed automatically
- ✅ **Service Management:** Systemd services, Nginx reverse proxy
- ✅ **Networking:** Private network, port forwarding

---

## 🔧 Common Commands

### Vagrant Management

```powershell
# On your Windows machine (C:\code\oci-devops-lab)

# Start VMs
vagrant up

# Stop VMs (saves state)
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

# View VM info
vagrant ssh-config
```

### Ansible (from VM1)

```bash
# Inside VM1

# Ping all hosts
ansible all -m ping

# Run ad-hoc command
ansible app_servers -m shell -a "uptime"

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

# Try reloading
vagrant reload
```

### Ansible Can't Connect to VM2

```bash
# From VM1

# Test SSH manually
ssh -i ~/.vagrant.d/insecure_private_key vagrant@192.168.56.11

# Check if VM2 is up
ping -c 3 192.168.56.11

# Re-run inventory test
ansible all -m ping -vvv
```

### Can't Access Flask App

```bash
# From VM1

# Check Flask service status
ansible app_servers -m shell -a "systemctl status flask-app"

# Check Nginx status
ansible app_servers -m shell -a "systemctl status nginx"

# Check firewall
ansible app_servers -m shell -a "firewall-cmd --list-services"

# Test locally on VM2
vagrant ssh vm2-app
curl http://localhost:5000
```

### Port 5000 Already in Use on Windows

```powershell
# Find what's using port 5000
netstat -ano | findstr :5000

# Kill the process (if safe)
Stop-Process -Id <PID> -Force

# Or change port in Vagrantfile:
# vm2.vm.network "forwarded_port", guest: 5000, host: 5001
```

---

## 📚 Next Steps

### Phase 6: Octopus Deploy Integration

1. Sign up for Octopus Cloud (free trial)
2. Install Tentacle on VMs
3. Create deployment project
4. Automate Flask app deployment via Octopus

### Phase 7: Terraform with Vagrant Provider

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

### Phase 8: Migrate to Cloud

Once comfortable locally:
- Use same Ansible playbooks on OCI/AWS/Azure
- Update inventory with cloud IPs
- Practice cloud-specific features (load balancers, auto-scaling)

---

## 💡 Pro Tips

**Snapshot VMs:**
```bash
# Take snapshot before risky changes
VBoxManage snapshot <vm-name> take "before-change"

# Restore if needed
VBoxManage snapshot <vm-name> restore "before-change"
```

**Faster Rebuilds:**
```powershell
# Destroy and recreate in one command
vagrant destroy -f && vagrant up
```

**Synced Folders:**
Uncomment in Vagrantfile to share code:
```ruby
config.vm.synced_folder ".", "/vagrant"
```

Then your Windows files appear at `/vagrant` in VMs!

---

## 📞 Support

**Issues?**
- Check `archive/` folder for OCI-specific docs
- Vagrant docs: https://www.vagrantup.com/docs
- Ansible docs: https://docs.ansible.com
- VirtualBox manual: https://www.virtualbox.org/manual

---

**Ready to learn DevOps the fast way!** 🚀

Start with:
```powershell
cd C:\code\oci-devops-lab
vagrant up
```
