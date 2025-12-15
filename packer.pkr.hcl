packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.5"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "proxmox_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type      = string
  sensitive = true
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "clone_vm_id" {
  type        = number
  description = "VM ID to clone from"
  default     = 9000
}

source "proxmox-clone" "ubuntu" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # Clone Settings
  clone_vm_id = var.clone_vm_id
  vm_name     = "ubuntu-golden-image"
  node        = "pve-1"

  # VM Settings
  cores   = 2
  memory  = 2048

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
  }

  # SSH Settings
  ssh_username = "ubuntu"
  ssh_password = var.password
  ssh_timeout  = "5m"
}

build {
  sources = ["source.proxmox-clone.ubuntu"]

  # Wait for system to be ready
  provisioner "shell" {
    inline = [
      "echo 'Waiting for system to stabilize...'",
      "sleep 10"
    ]
  }

  # System updates
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get autoremove -y",
      "sudo apt-get clean"
    ]
  }

  # Install useful packages
  provisioner "shell" {
    inline = [
      "sudo apt-get install -y curl wget git vim htop",
      "echo 'Golden image ready!'"
    ]
  }
}
