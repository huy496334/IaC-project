terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://192.168.56.101:8006/api2/json"
  pm_user         = "terraform_test"
  pm_password     = var.proxmox_password
  pm_tls_insecure = true
}

variable "proxmox_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

# Simple LXC Container PoC
resource "proxmox_lxc" "container_poc" {
  vmid             = 100
  nodeid           = "pve"
  hostname         = "poc-container"
  osimage          = "ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
  ostype           = "ubuntu"
  unprivileged     = true
  
  storage          = "local-lvm"
  rootfs_size      = "8G"
  
  memory           = 512
  swap             = 512
  cores            = 1
  
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }
  
  start       = true
  onboot      = true
  nameserver  = "8.8.8.8"
  searchdomain = "local"
  
  depends_on = [proxmox_vm_qemu.vm_poc]
}

# Simple QEMU/KVM Virtual Machine PoC
resource "proxmox_vm_qemu" "vm_poc" {
  vmid        = 200
  name        = "poc-vm"
  target_node = "pve"
  
  clone       = "ubuntu-22.04-template"
  cores       = 2
  sockets     = 1
  memory      = 2048
  
  disk {
    type     = "virtio"
    storage  = "local-lvm"
    size     = "20G"
  }
  
  network {
    model    = "virtio"
    bridge   = "vmbr0"
  }
  
  ciuser    = "ubuntu"
  cipassword = "password123"
  
  os_type   = "cloud-init"
  boot      = "order=virtio0"
  
  onboot    = true
  
  # Uncomment to enable auto-start
  # lifecycle {
  #   ignore_changes = [cipassword]
  # }
}

output "container_ip" {
  description = "IP address of the LXC container"
  value       = proxmox_lxc.container_poc.default_gateway
}

output "vm_id" {
  description = "VMID of the created virtual machine"
  value       = proxmox_vm_qemu.vm_poc.vmid
}
