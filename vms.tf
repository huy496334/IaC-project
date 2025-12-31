# VM Definitions for SOC Environment

# Wazuh SIEM Server
resource "proxmox_vm_qemu" "wazuh_server" {
  name            = "wazuh-server"
  vmid            = 151
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.50.10/24,gw=${var.soc_network_gateway}"
  skip_ipv6 = true
  start_at_node_boot = true
}

# Suricata IDS Server
resource "proxmox_vm_qemu" "suricata_ids" {
  name            = "suricata-ids"
  vmid            = 152
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.50.11/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true
}

# Zabbix + Grafana Monitoring Server
resource "proxmox_vm_qemu" "zabbix_grafana" {
  name            = "zabbix-grafana"
  vmid            = 153
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.50.20/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true
}

# GLPI Ticketing System
resource "proxmox_vm_qemu" "glpi_tickets" {
  name            = "glpi-tickets"
  vmid            = 154
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.50.30/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true
}

# T-Pot Honeypot Server
resource "proxmox_vm_qemu" "tpot_honeypot" {
  name            = "tpot-honeypot"
  vmid            = 155
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.honeypot_bridge
    tag    = var.honeypot_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.52.10/24,gw=${var.honeypot_network_gateway}"
  start_at_node_boot = true
}

# Infection Monkey Server (in SOC Network for testing)
resource "proxmox_vm_qemu" "infection_monkey" {
  name            = "infection-monkey"
  vmid            = 156
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
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
    slot    = "ide2"
  }
  
  network {
    id     = 0
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=192.168.50.40/24,gw=${var.soc_network_gateway}"
  start_at_node_boot = true
}

# Router VM for NAT and inter-VLAN routing
resource "proxmox_vm_qemu" "router" {
  name            = "router-nat"
  vmid            = 150
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = 1024
  scsihw          = "virtio-scsi-pci"
  boot            = "order=scsi0"
  
  cpu {
    cores = 1
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
    slot    = "ide2"
  }
  
  # WAN interface - connected to vmbr0 (internet)
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # SOC Network interface - gateway for 192.168.50.0/24
  network {
    id     = 1
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  # Honeypot Network interface - gateway for 192.168.52.0/24
  network {
    id     = 2
    model  = "virtio"
    bridge = var.honeypot_bridge
    tag    = var.honeypot_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  ipconfig0 = "ip=dhcp"
  ipconfig1 = "ip=${var.soc_network_gateway}/24"
  ipconfig2 = "ip=${var.honeypot_network_gateway}/24"
  start_at_node_boot = true
}
