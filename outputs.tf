# Outputs for SOC infrastructure

output "soc_network_info" {
  description = "SOC Network information"
  value = {
    vlan    = var.soc_network_vlan
    subnet  = var.soc_network_subnet
    gateway = var.soc_network_gateway
    bridge  = var.soc_bridge
  }
}

output "honeypot_network_info" {
  description = "Honeypot Network information"
  value = {
    vlan    = var.honeypot_network_vlan
    subnet  = var.honeypot_network_subnet
    gateway = var.honeypot_network_gateway
    bridge  = var.honeypot_bridge
  }
}
