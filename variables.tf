# Proxmox API Configuration
variable "proxmox_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

# Proxmox Node Configuration
variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

# Template Configuration
variable "template_name" {
  description = "Name of the cloud-init template"
  type        = string
  default     = "ubuntu-2404-cloudimg"
}

# Storage Configuration
variable "storage_pool" {
  description = "Storage pool name"
  type        = string
  default     = "local-lvm"
}

# Network Configuration - SOC Network (VLAN 50)
variable "soc_network_vlan" {
  description = "SOC Network VLAN ID"
  type        = number
  default     = 50
}

variable "soc_network_subnet" {
  description = "SOC Network subnet (CIDR)"
  type        = string
  default     = "192.168.50.0/24"
}

variable "soc_network_gateway" {
  description = "SOC Network gateway IP"
  type        = string
  default     = "192.168.50.254"
}

variable "soc_bridge" {
  description = "SOC Network bridge interface"
  type        = string
  default     = "vmbr50"
}

# Network Configuration - Honeypot Network (VLAN 52)
variable "honeypot_network_vlan" {
  description = "Honeypot Network VLAN ID"
  type        = number
  default     = 52
}

variable "honeypot_network_subnet" {
  description = "Honeypot Network subnet (CIDR)"
  type        = string
  default     = "192.168.52.0/24"
}

variable "honeypot_network_gateway" {
  description = "Honeypot Network gateway IP"
  type        = string
  default     = "192.168.52.254"
}

variable "honeypot_bridge" {
  description = "Honeypot Network bridge interface"
  type        = string
  default     = "vmbr52"
}

# VM Configuration
variable "vm_memory" {
  description = "Default VM memory in MB"
  type        = number
  default     = 1024
}

variable "vm_cores" {
  description = "Default VM CPU cores"
  type        = number
  default     = 1
}

variable "vm_sockets" {
  description = "Default VM CPU sockets"
  type        = number
  default     = 1
}

variable "vm_disk_size" {
  description = "Default VM disk size in GB"
  type        = number
  default     = 20
}

# SSH Configuration
variable "ssh_username" {
  description = "SSH username for VMs"
  type        = string
  default     = "ubuntu"
}

variable "ssh_password" {
  description = "SSH password for VMs"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VMs"
  type        = string
}