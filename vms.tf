# VM Definitions for SOC Environment

# Wazuh SIEM Server
resource "proxmox_vm_qemu" "wazuh_server" {
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "wazuh-server"
  vmid            = 151
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.50.10/24,gw=${var.soc_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "suricata-ids"
  vmid            = 152
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.50.11/24,gw=${var.soc_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "zabbix-grafana"
  vmid            = 153
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.50.20/24,gw=${var.soc_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "glpi-tickets"
  vmid            = 154
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.50.30/24,gw=${var.soc_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "tpot-honeypot"
  vmid            = 155
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.52.10/24,gw=${var.honeypot_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
  depends_on = [proxmox_vm_qemu.router]
  
  name            = "infection-monkey"
  vmid            = 156
  target_node     = var.proxmox_node
  clone           = var.template_name
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
  ipconfig0 = "ip=192.168.50.40/24,gw=${var.soc_network_gateway},nameserver=8.8.8.8 1.1.1.1"
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
# Router VM for VLAN Routing
resource "proxmox_vm_qemu" "router" {
  name            = "router"
  vmid            = 150
  target_node     = var.proxmox_node
  clone           = var.template_name
  full_clone      = true
  
  memory          = 2048
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
    slot    = "scsi2"
  }
  
  # Management interface (vmbr0) - DHCP
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  # SOC Network (vmbr50) - VLAN 50
  network {
    id     = 1
    model  = "virtio"
    bridge = var.soc_bridge
    tag    = var.soc_network_vlan
  }
  
  # Honeypot Network (vmbr52) - VLAN 52
  network {
    id     = 2
    model  = "virtio"
    bridge = var.honeypot_bridge
    tag    = var.honeypot_network_vlan
  }
  
  ciuser = var.ssh_username
  cipassword = var.ssh_password
  sshkeys = var.ssh_public_key
  ipconfig0 = "ip=192.168.1.201/24,gw=192.168.1.1,nameserver=192.168.1.3 1.1.1.1"
  ipconfig1 = "ip=192.168.50.254/24"
  ipconfig2 = "ip=192.168.52.254/24"
  start_at_node_boot = true
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "echo 'iptables-persistent iptables-persistent/autosave_v4 boolean true' | sudo debconf-set-selections",
      "echo 'iptables-persistent iptables-persistent/autosave_v6 boolean true' | sudo debconf-set-selections",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y net-tools isc-dhcp-server iptables-persistent ufw",
      "sudo apt upgrade -y",
      "sleep 3",
      "sudo mkdir -p /etc/iptables",
      "sudo sysctl -w net.ipv4.ip_forward=1",
      "echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf",
      "sleep 2",
      "sudo ip addr add 192.168.50.254/24 dev eth1 || true",
      "sudo ip addr add 192.168.52.254/24 dev eth2 || true",
      "sudo ip route add 192.168.50.0/24 via 192.168.50.254 dev eth1 || true",
      "sudo ip route add 192.168.52.0/24 via 192.168.52.254 dev eth2 || true",
      "sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
      "sudo iptables -t nat -A POSTROUTING -s 192.168.50.0/24 -d 192.168.52.0/24 -j MASQUERADE",
      "sudo iptables -t nat -A POSTROUTING -s 192.168.52.0/24 -d 192.168.50.0/24 -j MASQUERADE",
      "sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT",
      "sudo iptables -A FORWARD -i eth1 -o eth2 -j ACCEPT",
      "sudo iptables -A FORWARD -i eth2 -o eth1 -j ACCEPT",
      "sudo iptables -A FORWARD -i eth2 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT",
      "sudo iptables -A FORWARD -i eth0 -o eth2 -j ACCEPT",
      "sudo sh -c 'iptables-save > /etc/iptables/rules.v4' || true",
      "sudo systemctl restart netfilter-persistent || true",
      "sudo apt install -y qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent || true",
      "sudo sed -i 's/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/' /etc/default/ufw",
      "sudo ufw --force enable || true",
      "sudo ufw allow from 192.168.50.0/24 to 192.168.52.0/24 || true",
      "sudo ufw allow from 192.168.52.0/24 to 192.168.50.0/24 || true",
      "sudo ufw reload || true"
    ]
    
    connection {
      type        = "ssh"
      user        = var.ssh_username
      private_key = file("~/.ssh/id_ed25519")
      host        = "192.168.1.201"
      timeout     = "5m"
    }
  }
}
