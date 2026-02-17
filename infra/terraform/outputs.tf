# VM1 - Control Node Outputs
output "vm1_public_ip" {
  description = "Public IP of VM1 (Control Node)"
  value       = oci_core_instance.vm1_control.public_ip
}

output "vm1_private_ip" {
  description = "Private IP of VM1"
  value       = oci_core_instance.vm1_control.private_ip
}

output "vm1_id" {
  description = "OCID of VM1"
  value       = oci_core_instance.vm1_control.id
}

# VM2 - App Server Outputs
output "vm2_public_ip" {
  description = "Public IP of VM2 (App Server)"
  value       = oci_core_instance.vm2_app.public_ip
}

output "vm2_private_ip" {
  description = "Private IP of VM2"
  value       = oci_core_instance.vm2_app.private_ip
}

output "vm2_id" {
  description = "OCID of VM2"
  value       = oci_core_instance.vm2_app.id
}

# Network Outputs
output "vcn_id" {
  description = "VCN OCID"
  value       = oci_core_vcn.devops_vcn.id
}

output "public_subnet_id" {
  description = "Public Subnet OCID"
  value       = oci_core_subnet.public_subnet.id
}

output "private_subnet_id" {
  description = "Private Subnet OCID"
  value       = oci_core_subnet.private_subnet.id
}

# SSH Connection Info
output "ssh_to_vm1" {
  description = "SSH command for VM1"
  value       = "ssh -i ~/.ssh/id_rsa opc@${oci_core_instance.vm1_control.public_ip}"
}

output "ssh_to_vm2" {
  description = "SSH command for VM2 (from VM1 or if public IP assigned)"
  value       = oci_core_instance.vm2_app.public_ip != null ? "ssh -i ~/.ssh/id_rsa opc@${oci_core_instance.vm2_app.public_ip}" : "ssh -i ~/.ssh/id_rsa opc@${oci_core_instance.vm2_app.private_ip}"
}

# Ansible Inventory Format
output "ansible_inventory" {
  description = "Ansible inventory snippet (copy to config/ansible/inventory/hosts.yml)"
  value = <<-EOT
all:
  children:
    control:
      hosts:
        vm1:
          ansible_host: ${oci_core_instance.vm1_control.public_ip}
          ansible_user: opc
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
    app_servers:
      hosts:
        vm2:
          ansible_host: ${oci_core_instance.vm2_app.private_ip}
          ansible_user: opc
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
EOT
}
