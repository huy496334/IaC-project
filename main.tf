# Main Terraform configuration for SOC environment in Proxmox
# This file orchestrates the overall infrastructure


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
