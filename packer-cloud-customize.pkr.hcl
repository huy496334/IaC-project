# Packer configuration to customize Ubuntu Cloud Image template
# This clones the base cloud template, installs packages, and creates a new template

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

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "clone_vm" {
  type        = int
  description = "Name of the cloud template to clone"
}

variable "vm_id" {
  type        = number
  default     = 9003
  description = "VMID for the new customized template"
}

variable "template_name" {
  type    = string
  default = "ubuntu-cloud-custom"
}

variable "ubuntu_username" {
  type = string
}

variable "ubuntu_password" {
  type      = string
  sensitive = true
}

source "proxmox-clone" "ubuntu-cloud-custom" {
  # Proxmox connection
  proxmox_url              = var.proxmox_url
  username                 = var.username
  password                 = var.password
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # Clone settings
  clone_vm   = var.clone_vm
  vm_id      = var.vm_id
  vm_name    = var.template_name
  full_clone = true

  # VM configuration - match the template
  cores   = 2
  memory  = 2048
  os      = "l26"
  scsihw  = "virtio-scsi-pci"
  qemu_agent = true

  # Preserve template disk - don't reconfigure
  # The cloned disk from template will be used as-is

  # Network for provisioning (use vmbr0 for internet access during build)
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # Cloud-init settings for Packer to connect
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"
  
  # Set IP via DHCP for provisioning
  ipconfig {
    ip = "dhcp"
  }
  
  # Add VirtIO RNG for entropy (fixes crng init stuck issue)
  rng0 {
    source    = "/dev/urandom"
    max_bytes = 1024
    period    = 1000
  }

  # SSH connection
  ssh_username = var.ubuntu_username
  ssh_password = var.ubuntu_password
  ssh_timeout  = "20m"

  # Convert to template when done
  template_name        = var.template_name
  template_description = "Ubuntu 24.04 Cloud Image - Customized with qemu-guest-agent and updates"
}

build {
  sources = ["source.proxmox-clone.ubuntu-cloud-custom"]

  # Wait for cloud-init to complete
  provisioner "shell" {
    inline = [
      "echo 'Waiting for cloud-init to complete...'",
      "sudo cloud-init status --wait",
      "echo 'Cloud-init completed!'"
    ]
  }

  # Update system and install qemu-guest-agent
  provisioner "shell" {
    inline = [
      "echo 'Updating package lists...'",
      "sudo apt-get update",
      
      "echo 'Upgrading packages...'",
      "sudo apt-get upgrade -y",
      
      "echo 'Installing qemu-guest-agent...'",
      "sudo apt-get install -y qemu-guest-agent",
      
      "echo 'Enabling qemu-guest-agent service...'",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
  }

  # Clean up for templating
  provisioner "shell" {
    inline = [
      "echo 'Cleaning up for template...'",
      
      "# Clean apt cache",
      "sudo apt-get clean",
      "sudo apt-get autoremove -y",

      "echo 'Template cleanup complete!'"
    ]
  }
}
