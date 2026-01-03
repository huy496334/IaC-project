# Packer Golden Image for Proxmox

Bouw een golden image (VM template) voor Proxmox met Packer.

## Setup

### Requirements
- Packer >= 1.8.0
- Terraform >= 1.0 (optional, voor deployment)
- Proxmox 7.0+ met API access

### Variables

Maak `packer.pkrvars.hcl` aan met je credentials:

```hcl
proxmox_api_token_id     = "user@pam!tokenname"
proxmox_api_token_secret = "token-secret-here"
username                 = "terraform@pve"
password                 = "your-password"
```

⚠️ **LET OP**: `packer.pkrvars.hcl` staat in `.gitignore` - push je credentials nooit!

## Build

### Valideren
```powershell
packer validate -var-file="packer.pkrvars.hcl" packer.pkr.hcl
```

### Builden
```powershell
packer build -var-file="packer.pkrvars.hcl" packer.pkr.hcl
```

Dit maakt een VM template `ubuntu-template` (VM ID 9000) in Proxmox.

## Huidge Config

- **Base Image**: Ubuntu 24.04 Noble Cloud Image
- **Storage**: local-lvm
- **Disk Format**: raw
- **CPU**: 2 cores
- **Memory**: 2048 MB
- **Cloud-init**: enabled

## Troubleshooting

### KVM virtualization error
Als je krijgt: "KVM virtualisation configured, but not available"

**In Proxmox (nested virt in VirtualBox):**
```bash
modprobe kvm_amd
echo 1 > /sys/module/kvm_amd/parameters/nested
```

Of fix boot order in VirtualBox Proxmox VM settings.

### ISO not found
Zorg dat `noble-server-cloudimg-amd64.img` in Proxmox storage staat:
- Path: `local:iso/noble-server-cloudimg-amd64.img`

## Volgende stappen

- [ ] Fix KVM nested virtualization
- [ ] Voer packer build succesvol uit
- [ ] Test template met Terraform deployment
- [ ] Voeg provisioners toe (packages, scripts, etc)

## Resources

- [Packer Proxmox Plugin](https://developer.hashicorp.com/packer/integrations/proxmox/proxmox)
- [Proxmox Nested Virtualization](https://pve.proxmox.com/wiki/Nested_Virtualization)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
