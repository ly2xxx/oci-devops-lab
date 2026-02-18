# -*- mode: ruby -*-
# vi: set ft=ruby :

# DevOps Lab - Vagrant Configuration
# Creates 2 VMs for Terraform + Ansible + Octopus learning
# VM1: Control node (Terraform, Ansible)
# VM2: App server (Nginx, Flask demo)

Vagrant.configure("2") do |config|
  
  # Common settings for all VMs
  config.vm.box = "generic/oracle8"  # Oracle Linux 8 (similar to OCI)
  config.vm.box_check_update = false
  
  # VM1 - Control Node
  config.vm.define "vm1-control", primary: true do |vm1|
    vm1.vm.hostname = "vm1-control"
    
    # Network: Private network for inter-VM communication
    vm1.vm.network "private_network", ip: "192.168.56.10"
    
    # Port forwarding (optional, for accessing services from host)
    # vm1.vm.network "forwarded_port", guest: 8080, host: 8080
    
    # VirtualBox provider settings
    vm1.vm.provider "virtualbox" do |vb|
      vb.name = "devops-lab-vm1-control"
      vb.memory = "2048"  # 2GB RAM (much better than OCI's 1GB!)
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    # Provisioning: Install Terraform + Ansible
    vm1.vm.provision "shell", inline: <<-SHELL
      echo "=== Provisioning VM1 (Control Node) ==="
      
      # Set timezone
      timedatectl set-timezone Europe/London
      
      # Skip full system update (causes SSH timeout)
      # Can update manually later: sudo yum update -y
      
      # Install basic tools
      yum install -y git wget curl vim unzip python3 python3-pip
      
      # Install Terraform
      echo "Installing Terraform..."
      cd /tmp
      wget -q https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
      unzip -o terraform_1.7.5_linux_amd64.zip
      mv terraform /usr/local/bin/
      chmod +x /usr/local/bin/terraform
      rm terraform_1.7.5_linux_amd64.zip
      
      # Install Ansible
      echo "Installing Ansible..."
      pip3 install --upgrade pip
      pip3 install ansible
      
      # Create workspace
      mkdir -p /home/vagrant/workspace
      chown -R vagrant:vagrant /home/vagrant/workspace
      
      # Create SSH key for Ansible (no passphrase)
      if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
        sudo -u vagrant ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
      fi
      
      echo "VM1 provisioning complete!"
      echo "Terraform: $(terraform --version | head -1)"
      echo "Ansible: $(ansible --version | head -1)"
    SHELL
  end
  
  # VM2 - App Server
  config.vm.define "vm2-app" do |vm2|
    vm2.vm.hostname = "vm2-app"
    
    # Network: Private network for inter-VM communication
    vm2.vm.network "private_network", ip: "192.168.56.11"
    
    # Port forwarding: Access Flask app from host browser
    vm2.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
    vm2.vm.network "forwarded_port", guest: 5000, host: 5000, host_ip: "127.0.0.1"
    
    # VirtualBox provider settings
    vm2.vm.provider "virtualbox" do |vb|
      vb.name = "devops-lab-vm2-app"
      vb.memory = "2048"  # 2GB RAM
      vb.cpus = 2
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
      vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end
    
    # Provisioning: Basic setup (Ansible will do the rest)
    vm2.vm.provision "shell", inline: <<-SHELL
      echo "=== Provisioning VM2 (App Server) ==="
      
      # Set timezone
      timedatectl set-timezone Europe/London
      
      # Skip full system update (causes SSH timeout)
      # Can update manually later: sudo yum update -y
      
      # Install basic tools
      yum install -y git wget curl vim python3 python3-pip
      
      # Configure firewall (allow HTTP, HTTPS, SSH)
      firewall-cmd --permanent --add-service=ssh
      firewall-cmd --permanent --add-service=http
      firewall-cmd --permanent --add-service=https
      firewall-cmd --reload
      
      echo "VM2 provisioning complete!"
    SHELL
    
    # Copy VM1's SSH public key to VM2 for passwordless SSH
    vm2.vm.provision "shell", inline: <<-SHELL
      # This will be added by Ansible in practice
      # For now, Vagrant handles SSH key exchange automatically
      echo "VM2 ready for Ansible configuration from VM1"
    SHELL
  end
  
  # Synced folders (optional)
  # Share your project code with VMs
  # config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  
end

# Post-up instructions
# After 'vagrant up' completes:
#
# 1. SSH to VM1:
#    vagrant ssh vm1-control
#
# 2. Verify installations:
#    terraform --version
#    ansible --version
#
# 3. Test connectivity to VM2:
#    ping -c 3 192.168.56.11
#    ssh vagrant@192.168.56.11  (password: vagrant)
#
# 4. Clone your repo:
#    cd ~/workspace
#    git clone https://github.com/YOUR_USERNAME/oci-devops-lab.git
#
# 5. Run Ansible playbooks from VM1 to configure VM2
#
# Access Flask app from your browser:
#    http://localhost:5000  (after Ansible deploys it)
