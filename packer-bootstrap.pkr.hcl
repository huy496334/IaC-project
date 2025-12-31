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

variable "username" {
  type = string
}

variable "ubuntu_username" {
  type      = string
}

variable "ubuntu_password" {
  type      = string
  sensitive = true
}

# Bootstrap VM template from Ubuntu ISO
source "proxmox-iso" "ubuntu-bootstrap" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # VM Settings
  node     = "pve"
  vm_id    = 9001
  vm_name  = "ubuntu-base"
  template_description = "ubuntu 24.04.3 LTS bootstrap template created by Packer"

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Ubuntu Server ISO (live installer)
  boot_iso {
    type    = "scsi"
    iso_file = "local:iso/ubuntu-24.04.3-live-server-amd64.iso"
    unmount = true
    keep_cdrom_device = false
  }

  # VM System Settings
  qemu_agent = true
  cores   = 2
  memory  = 2048

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  # HTTP server for cloud-init
  http_directory    = "http"

  # Packer commands to automate the installation
  boot_wait    = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>",
  ]

  # SSH access
  ssh_username = var.ubuntu_username
  ssh_password = var.ubuntu_password

  # Raise the timeout if the installation takes longer
  ssh_timeout  = "5m"
}

build {
  name = "ubuntu-24.04.3-bootstrap"
  sources = ["source.proxmox-iso.ubuntu-bootstrap"]

  # System updates
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]
  }

  # Clean up
  provisioner "shell" {
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get clean",
      "echo 'Bootstrap complete - VM is ready for cloning'"
    ]
  }
}
