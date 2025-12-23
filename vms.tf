# VM Definitions for SOC Environment

# Wazuh SIEM Server
resource "proxmox_vm_qemu" "wazuh_server" {
  name            = "wazuh-server"
  vmid            = 150
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory * 2  # Wazuh needs more memory
  cores           = var.vm_cores * 2
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.10/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}

# Suricata IDS Server
resource "proxmox_vm_qemu" "suricata_ids" {
  name            = "suricata-ids"
  vmid            = 151
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.11/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}

# Zabbix Monitoring Server
resource "proxmox_vm_qemu" "zabbix_monitor" {
  name            = "zabbix-monitor"
  vmid            = 152
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.20/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}

# Grafana Visualization Server
resource "proxmox_vm_qemu" "grafana_viz" {
  name            = "grafana-viz"
  vmid            = 153
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.21/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}

# GLPI Ticketing System
resource "proxmox_vm_qemu" "glpi_tickets" {
  name            = "glpi-tickets"
  vmid            = 154
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.30/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}

# T-Pot Honeypot Server
resource "proxmox_vm_qemu" "tpot_honeypot" {
  name            = "tpot-honeypot"
  vmid            = 156
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory * 2
  cores           = var.vm_cores * 2
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size * 2}G"  # Honeypots generate lots of logs
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.honeypot_bridge
    tag    = var.honeypot_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.52.10/24,gw=${var.honeypot_network_gateway}"
  
  onboot = true
}

# Infection Monkey Server (in SOC Network for testing)
resource "proxmox_vm_qemu" "infection_monkey" {
  name            = "infection-monkey"
  vmid            = 155
  target_node     = var.proxmox_node
  clone           = var.packer_image_name
  full_clone      = true
  
  memory          = var.vm_memory
  cores           = var.vm_cores
  sockets         = var.vm_sockets
  
  disk {
    size    = "${var.vm_disk_size}G"
    storage = var.storage_pool
    type    = "virtio"
  }
  
  network {
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  lifecycle {
    ignore_changes = [network]
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  
  ipconfig0 = "ip=192.168.50.40/24,gw=${var.soc_network_gateway}"
  
  onboot = true
}
