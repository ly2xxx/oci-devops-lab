# OCI Authentication
variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint of the API key"
  type        = string
}

variable "private_key_path" {
  description = "Path to your OCI API private key"
  type        = string
  default     = "~/.oci/oci_api_key.pem"
}

variable "region" {
  description = "OCI region (e.g., uk-london-1, eu-frankfurt-1)"
  type        = string
  default     = "uk-london-1"
}

# Compartment
variable "compartment_ocid" {
  description = "OCID of the compartment (use root compartment for simplicity)"
  type        = string
}

# Network Configuration
variable "vcn_cidr" {
  description = "CIDR block for VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Compute Configuration
variable "ssh_public_key_path" {
  description = "Path to SSH public key for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "availability_domain" {
  description = "Availability domain number (1, 2, or 3)"
  type        = number
  default     = 1
}

# Always Free Shape
variable "instance_shape" {
  description = "Compute shape (Always Free: VM.Standard.E2.1.Micro)"
  type        = string
  default     = "VM.Standard.E2.1.Micro"
}

# Image OCID (Oracle Linux 8)
# Find latest: https://docs.oracle.com/en-us/iaas/images/
variable "instance_image_ocid" {
  description = "OCID of the OS image (Oracle Linux 8)"
  type        = string
  # This is a placeholder - get actual OCID from OCI console or use data source
  default     = ""
}
