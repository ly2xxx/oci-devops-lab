# VM1 - Control Node (Public Subnet)
resource "oci_core_instance" "vm1_control" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1].name
  shape               = var.instance_shape
  display_name        = "vm1-control-node"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = true
    display_name     = "vm1-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid != "" ? var.instance_image_ocid : data.oci_core_images.ol8.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/cloud-init-vm1.sh", {
      hostname = "vm1-control"
    }))
  }

  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }

  preserve_boot_volume = false
}

# VM2 - App Server (Private/Public Subnet)
resource "oci_core_instance" "vm2_app" {
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1].name
  shape               = var.instance_shape
  display_name        = "vm2-app-server"

  create_vnic_details {
    subnet_id        = oci_core_subnet.private_subnet.id
    assign_public_ip = true # Set to false for truly private VM
    display_name     = "vm2-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid != "" ? var.instance_image_ocid : data.oci_core_images.ol8.images[0].id
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key_path)
    user_data = base64encode(templatefile("${path.module}/cloud-init-vm2.sh", {
      hostname = "vm2-app"
    }))
  }

  shape_config {
    memory_in_gbs = 1
    ocpus         = 1
  }

  preserve_boot_volume = false
}

# Optional: VM3 - Database/Extra App Server
# Uncomment to enable

# resource "oci_core_instance" "vm3_db" {
#   compartment_id      = var.compartment_ocid
#   availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.availability_domain - 1].name
#   shape               = var.instance_shape
#   display_name        = "vm3-database"
#
#   create_vnic_details {
#     subnet_id        = oci_core_subnet.private_subnet.id
#     assign_public_ip = false
#     display_name     = "vm3-vnic"
#   }
#
#   source_details {
#     source_type = "image"
#     source_id   = var.instance_image_ocid != "" ? var.instance_image_ocid : data.oci_core_images.ol8.images[0].id
#   }
#
#   metadata = {
#     ssh_authorized_keys = file(var.ssh_public_key_path)
#     user_data = base64encode(templatefile("${path.module}/cloud-init-vm3.sh", {
#       hostname = "vm3-db"
#     }))
#   }
#
#   shape_config {
#     memory_in_gbs = 1
#     ocpus         = 1
#   }
#
#   preserve_boot_volume = false
# }
