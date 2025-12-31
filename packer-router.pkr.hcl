packer {
  required_plugins {
    proxmox = {
      version = "1.2.3"
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

variable "ubuntu_username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "ubuntu_password" {
  type      = string
  sensitive = true
}

variable "clone_vm_id" {
  type        = number
  description = "VM ID to clone from"
  default     = 9000
}

# Router template cloned from golden image
source "proxmox-clone" "router" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # Clone Settings
  clone_vm_id = var.clone_vm_id
  vm_name     = "router-template"
  node        = "pve"
  vm_id       = 9002

  # VM Settings
  qemu_agent = true
  cores   = 2
  memory  = 2048

  disks {
    disk_size    = "20G"
    storage_pool = "local-lvm"
  }

  # SSH Settings
  ssh_username = var.ubuntu_username
  ssh_password = var.ubuntu_password
  ssh_timeout  = "5m"
}

build {
  name    = "router-template"
  sources = ["source.proxmox-clone.router"]

  # Wait for system to be ready
  provisioner "shell" {
    inline = [
      "echo 'Waiting for system to stabilize...'",
      "sleep 10"
    ]
  }

  # Install router-specific packages and setup
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y iptables-persistent netfilter-persistent",
    ]
  }

  # Enable IP forwarding
  provisioner "shell" {
    inline = [
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "sudo sh -c 'echo net.ipv4.ip_forward=1 >> /etc/sysctl.conf'",
      "echo 'IP forwarding enabled'"
    ]
  }

  # Clean up
  provisioner "shell" {
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "echo 'Router template complete - VM is ready for cloning'"
    ]
  }
}
