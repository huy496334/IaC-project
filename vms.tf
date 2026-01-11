# VM Definitions for SOC Environment

# Wazuh SIEM Server
resource "proxmox_vm_qemu" "wazuh_server" {
  name            = "wazuh-server"
  vmid            = 151
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores * 2
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.50.10/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.50.10"
      timeout     = "5m"
    }
  }
}

# Suricata IDS Server
resource "proxmox_vm_qemu" "suricata_ids" {
  name            = "suricata-ids"
  vmid            = 152
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.50.11/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.50.11"
      timeout     = "5m"
    }
  }
}

# Zabbix + Grafana Monitoring Server
resource "proxmox_vm_qemu" "zabbix_grafana" {
  name            = "zabbix-grafana"
  vmid            = 153
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores * 2
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.50.20/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.50.20"
      timeout     = "5m"
    }
  }
}

# GLPI Ticketing System
resource "proxmox_vm_qemu" "glpi_tickets" {
  name            = "glpi-tickets"
  vmid            = 154
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.50.30/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.50.30"
      timeout     = "5m"
    }
  }
}

# T-Pot Honeypot Server
resource "proxmox_vm_qemu" "tpot_honeypot" {
  name            = "tpot-honeypot"
  vmid            = 155
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores * 2
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size * 2
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.honeypot_bridge
    tag    = var.honeypot_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.52.10/24,gw=${var.honeypot_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.52.10"
      timeout     = "5m"
    }
  }
}

# Infection Monkey Server (in SOC Network for testing)
resource "proxmox_vm_qemu" "infection_monkey" {
  name            = "infection-monkey"
  vmid            = 156
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  serial {
    id   = 0
    type = "socket"
  }
  
  vga {
    type = "serial0"
  }
  
  cpu {
    cores = var.vm_cores
  }
  
  disk {
    type    = "disk"
    storage = var.storage_pool
    size    = var.vm_disk_size
    slot    = "scsi0"
  }
  
  disk {
    type    = "cloudinit"
    storage = var.storage_pool
    slot    = "scsi2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.50.40/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y qemu-guest-agent",
      "sudo apt upgrade -y",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent"
    ]

    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.50.40"
      timeout     = "5m"
    }
  }
}
