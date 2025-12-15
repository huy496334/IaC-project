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

source "proxmox-iso" "ubuntu" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # VM General Settings
  node     = "pve-1"
  vm_id    = 9000
  vm_name  = "ubuntu-template"
  template_description = "Ubuntu 24.04 VM Template"

  cores   = 2
  memory  = 2048
  
  qemu_agent = true
  
  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
  }

  disks {
    disk_size         = "20G"
    format            = "qcow2"
    storage_pool      = "local-lvm"
    type              = "virtio"
  }
  
  boot_iso {
    type         = "scsi"
    iso_file     = "local:iso/noble-server-cloudimg-amd64.img"
    unmount      = true
  }

  cloud_init = true
  cloud_init_storage_pool = "local-lvm"

  ssh_username = "student"
  ssh_password = var.password
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  # Disable KVM acceleration for nested virtualization
  provisioner "shell" {
    inline = [
      "echo 'Configuring for nested virtualization'",
      "sleep 5"
    ]
  }

  # Simple shell provisioner
  provisioner "shell" {
    inline = [
      "echo 'Hello from Packer!'",
      "apt-get update && apt-get upgrade -y"
    ]
  }
}
