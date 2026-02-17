# Get list of availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Auto-fetch latest Oracle Linux 8 image
data "oci_core_images" "ol8" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = var.instance_shape
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Virtual Cloud Network (VCN)
resource "oci_core_vcn" "devops_vcn" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "devops-lab-vcn"
  dns_label      = "devopsvcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "devops_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devops_vcn.id
  display_name   = "devops-lab-igw"
  enabled        = true
}

# Route Table for Public Subnet
resource "oci_core_route_table" "public_rt" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devops_vcn.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.devops_igw.id
  }
}

# Security List for Public Subnet
resource "oci_core_security_list" "public_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devops_vcn.id
  display_name   = "public-security-list"

  # Egress Rules (Outbound)
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  # Ingress Rules (Inbound)
  
  # SSH (22) - from anywhere
  ingress_security_rules {
    protocol    = "6" # TCP
    source      = "0.0.0.0/0"
    description = "SSH access"

    tcp_options {
      min = 22
      max = 22
    }
  }

  # HTTP (80)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTP access"

    tcp_options {
      min = 80
      max = 80
    }
  }

  # HTTPS (443)
  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "HTTPS access"

    tcp_options {
      min = 443
      max = 443
    }
  }

  # ICMP (Ping)
  ingress_security_rules {
    protocol    = "1" # ICMP
    source      = "0.0.0.0/0"
    description = "ICMP ping"
  }
}

# Security List for Private Subnet
resource "oci_core_security_list" "private_sl" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.devops_vcn.id
  display_name   = "private-security-list"

  # Egress - Allow all outbound
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound"
  }

  # Ingress - Allow from VCN only
  ingress_security_rules {
    protocol    = "all"
    source      = var.vcn_cidr
    description = "Allow all from VCN"
  }
}

# Public Subnet (for VM1 - Control Node)
resource "oci_core_subnet" "public_subnet" {
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_vcn.devops_vcn.id
  cidr_block        = var.public_subnet_cidr
  display_name      = "public-subnet"
  dns_label         = "public"
  route_table_id    = oci_core_route_table.public_rt.id
  security_list_ids = [oci_core_security_list.public_sl.id]
}

# Private Subnet (for VM2 - App Server)
resource "oci_core_subnet" "private_subnet" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.devops_vcn.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "private-subnet"
  dns_label                  = "private"
  prohibit_public_ip_on_vnic = false # Set to true for truly private subnet
  route_table_id             = oci_core_route_table.public_rt.id
  security_list_ids          = [oci_core_security_list.private_sl.id]
}
