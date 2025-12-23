terraform {
  required_version = ">= 1.0"
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "~> 2.9"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.proxmox_url
  pm_user         = var.proxmox_api_token_id
  pm_password     = var.proxmox_api_token_secret
  pm_tls_insecure = true
}
