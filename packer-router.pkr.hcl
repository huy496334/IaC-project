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

variable "ubuntu_password" {
  type      = string
  sensitive = true
}

# Router template from Ubuntu ISO
source "proxmox-iso" "router" {
  # Proxmox Connection Settings
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true

  # VM Settings
  node                 = "pve"
  vm_id                = 9001
  vm_name              = "router-template"
  template_description = "Ubuntu 24.04.3 LTS router template with IP forwarding"

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
  http_directory = "http"

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
  ssh_username = "ubuntu"
  ssh_password = var.ubuntu_password

  # Raise the timeout if the installation takes longer
  ssh_timeout  = "20m"
}

build {
  name    = "router-template"
  sources = ["source.proxmox-iso.router"]

  # Wait for cloud-init
  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "echo 'Cloud-init completed'"
    ]
  }

  # Install router-specific packages and setup
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y qemu-guest-agent iptables-persistent netfilter-persistent",
      "sudo systemctl enable qemu-guest-agent"
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
