# Onderzoeksdocument SOC-omgeving met IaC op Proxmox

Versie: 0.1 (concept)
Auteur: Huy
Datum: 18-12-2025

## Samenvatting
Dit document onderzoekt hoe Infrastructure as Code (IaC) kan worden ingezet om een veilige, schaalbare en reproduceerbare SOC-omgeving geautomatiseerd uit te rollen in Proxmox. De aanbevolen stack bestaat uit Packer (golden images), Terraform (infrastructuur) en Ansible (configuratie), met Git voor versiebeheer en rollback.

## 1. Inleiding
### 1.1 Hoofdvraag
Hoe kan Infrastructure as Code (IaC) worden ingezet om een veilige, schaalbare en reproduceerbare SOC-omgeving geautomatiseerd uit te rollen in Proxmox, ter ondersteuning van blue teamers en toekomstige studenten?

### 1.2 Deelvragen
1. Welke bekende IaC-tools worden er gebruikt om IT-omgevingen uit te rollen?
2. Hoe kan ik versiebeheer en rollback implementeren op het IaC-bestand?
3. Hoe ziet de SOC-omgeving eruit die op het SecLab draait?
4. Welke applicaties worden er gebruikt in mijn IaC-product?
5. Welke risico's blijven bestaan, ook al worden IaC en veiligheidsstructuren toegepast?

### 1.3 Doel, scope en stakeholders
- Doel: reproduceerbare, gedocumenteerde SOC-omgeving voor onderwijs en oefening.
- Scope: Proxmox-VM's, netwerksegmentatie (VLAN 50/52), golden images, provisioning, basisbeveiliging, CI/CD, testplan.
- Out-of-scope: Volledige enterprise-SIEM integratie en productieschaal; diepgaande app-tuning per SOC-tool.
- Stakeholders: Infra/NetOps, SecOps/blue team, docenten/leerlingen.

### 1.4 Methodologie
Literatuurstudie en vergelijking van tools, analyse bestaande SecLab-omgeving, ontwerp nieuw concept, proof-of-concept met Packer→Terraform→Ansible, evaluatie op reproduceerbaarheid, eenvoud en beheersbaarheid.

## 2. Keuze IaC-stack
### 2.1 Terraform vs Pulumi
| Kenmerk | Terraform | Pulumi |
|---|---|---|
| Type | Declaratieve IaC | Programmeerbare IaC (Python/Go/TS/C#) |
| Declaratief | Ja | Nee, je schrijft code |
| Proxmox-ondersteuning | Ja (telmate/proxmox) | Via API/SDK, minder native |
| Community/tutorials | Groot | Kleiner |
| Integratie met Packer | Ja | Mogelijk, minder gestroomlijnd |
| State management | Ingebouwd | Zelf inrichten |

Conclusie: Terraform werkt beter met Proxmox en integreert prettig met Packer voor golden images. Pulumi biedt flexibiliteit maar is minder direct passend voor deze use case.

### 2.2 Ansible vs Chef vs Puppet
| Kenmerk | Ansible | Chef | Puppet |
|---|---|---|---|
| Type | Config management | Config management | Config management |
| Agent | Agentless (SSH) | Vereist agent | Vereist agent |
| Declaratief | Ja | Ja | Ja |
| Complexiteit | Laag | Hoog | Hoog |
| Community/tutorials | Groot | Groot (enterprise) | Groot (enterprise) |
| Geschikt voor SOC-lab | Ja | Minder geschikt | Minder geschikt |
| Gebruik in oude SOC-docs | Ja | Nee | Nee |

Conclusie: Ansible is de beste keuze voor een lichtgewicht, agentless workflow die past bij het SOC-lab.

### 2.3 Packer: Golden images voor Proxmox
Packer maakt vooraf geconfigureerde golden images met OS, updates, hardening en basisconfiguratie. Voordeel: minder fouten tijdens uitrol, consistente basis en sneller schalen.

### 2.4 Versiebeheer en rollback met Git
- Traceerbaarheid per commit/PR, branches en releases (SemVer). 
- Rollback via `git revert` of terug naar een vorige tag. 
- Integratie met CI/CD voor linting, validatie, build en deployment. 
- Repo: https://github.com/huy496334/IaC-project

### 2.5 Aanbevolen workflow SOC-omgeving
1) Packer bouwt golden images. 2) Terraform rolt VM's/netwerk in Proxmox uit. 3) Ansible configureert SOC-applicaties. 

[Diagram placeholder: Workflow Packer→Terraform→Ansible]

### 2.6 Conclusie tools
Combinatie Packer + Terraform + Ansible levert een efficiënte, reproduceerbare en eenvoudig te beheren SOC-omgeving op. Chef/Puppet zijn zwaarder en minder passend voor dit educatieve doel.

## 3. Inventarisatie en netwerk
### 3.1 Netwerkinfrastructuur overzicht (huidig SecLab)
- Drie VLAN's in totaal; focus op twee: 
  - Educational-SOC Exploit Network (Honeypot)
  - Educational-SOC Network (Applicaties)
- Exploit-netwerk voor gesimuleerde dreigingen en honeypots; Applicatienetwerk voor SIEM/monitoring.

[Diagram placeholder: Netwerktekening oude SecLab]

### 3.2 Analyse functionaliteiten
- Zabbix/Grafana: infra-monitoring en dashboards.
- Elasticsearch/Kibana: logopslag/visualisatie; basis SIEM-functionaliteit maar veel handmatige inrichting.
- Elastic Fleet: aparte server voor agentbeheer; policies; log shipping.
- GLPI: ticketing voor incidenten/onderhoud.
- Ansible/AWX: automatisering en provisioning van VM's en apps.
- Suricata: IDS op Exploit-netwerk; alerts naar SIEM/logs.
- Infection Monkey: gecontroleerde aanvallen om detectie te testen.

#### 3.2.1 Beoordeling huidige omgeving
Elastic Stack is krachtig, maar voor een leerbare SIEM-ervaring is Wazuh logischer (meer geïntegreerd, minder losse componenten). Documentatie vorige SecLab-groep is installatiegericht; functionele samenhang en gebruik ontbreken.

#### 3.2.2 Conclusie analyse
Tools vullen elkaar aan, maar voor onderwijsdoeleinden is eenvoud en integratie belangrijk. Wazuh sluit beter aan op de SOC-doelen (centrale correlatie, integratie met Suricata) dan een losse Elastic-stack.

### 3.3 Voorstel nieuwe omgeving
#### 3.3.1 Applicaties en rollen
- Wazuh (SIEM): centrale correlatie, detectie en analyse.
- Suricata (IDS): netwerkdetectie in Exploit-netwerk, alerts naar SIEM.
- Zabbix/Grafana: systeemprestaties en beschikbaarheid.
- GLPI: ticketing en opvolging.
- Ansible/AWX: automatisering voor provisioning/configuratie.
- Infection Monkey: simulaties voor leerdoeleinden.
- T-Pot: honeypot-platform voor realistische aanvalstelemetrie naar SIEM.

#### 3.3.2 Netwerkinfrastructuur (nieuw ontwerp)
- Educational-SOC Network (VLAN 50): 192.168.50.0/24, GW 192.168.50.254; SIEM/monitoring/ticketing.
- Honeypot Network (VLAN 52): 192.168.52.0/24, GW 192.168.52.254; T-Pot/honeypots. 
- Telemetrie stroomt van Honeypot→SOC; segmentatie en firewalling borgen scheiding.

[Diagram placeholder: Netwerkomgeving voor IaC-product]

## 4. Security & Compliance
- Threat model: misconfiguratie, secret-lekken, drift, kwetsbare images.
- Hardening: CIS-baseline, SSH-policy, updates, auditd, fail2ban (indien passend).
- Secrets: Vault/Ansible Vault; nooit in Git in plain text.
- RBAC: Proxmox API-rollen, beperkt tokengebruik, minimaal privilege.
- Certificate/PKI: beheer en rotatie. 

## 5. Architectuur & Ontwerpkeuzes
- Proxmox: nodes, pools, storage (local-lvm/ceph), bridges (vmbrX), VLAN-tagging.
- VM sizing: CPU/RAM/disk per rol; groeimarge. 
- Naming/tagging: consistente namen, VMID-reserveringen, labels.
- Cloud-init: gebruikers, SSH-keys, netplan, userdata.

## 6. CI/CD & Kwaliteit
- Stages: `fmt/lint` → `validate` → `build` → `test` → `deploy`.
- Gates: PR-reviews, policy checks, testuitslagen.
- Artefacten: Packer image tags (SemVer), Terraform state, Ansible collections.

## 7. Test- en validatieplan
- Linting: `packer fmt/validate`, `ansible-lint`, `terraform fmt/validate`.
- Integratie/smoke: cloud-init voltooiing, service health endpoints, poortchecks.
- Netwerk: VLAN-tagging correct, route/gw/DNS, isolatie.
- Rollbackcriteria: objectieve thresholds; herstelstappen en fallback-image.

## 8. Risico’s en mitigatie
| Risico | Impact | Kans | Mitigatie |
|---|---|---|---|
| Config drift | Hoog | Middel | Ansible idempotent runs, immutable images |
| Secret leakage | Hoog | Laag | Vault, scannen, geen secrets in Git |
| Verouderde images | Middel | Middel | Periodieke rebuilds, patchbeleid |
| Vendor lock-in | Laag | Laag | Gebruik open standaarden, exporteerbare artefacten |

## 9. Traceerbaarheid (Vraag → Sectie → Artefact)
| Vraag | Sectie | Artefact |
|---|---|---|
| Hoofdvraag | 2,3,5,6,7,10 | Packer/Terraform/Ansible pipeline + ontwerp |
| 1 | 2 | Vergelijkingstabellen en conclusies |
| 2 | 2.4,6 | Git-strategie, rollback stappen |
| 3 | 3.1 | Inventarisatie en diagram |
| 4 | 3.2–3.3 | Applicatierollen, nieuw ontwerp |
| 5 | 4,8 | Risico's en mitigaties |

## 10. Conclusie
Packer + Terraform + Ansible, gestuurd via Git en CI/CD, biedt een herhaalbare en leerbare SOC-omgeving op Proxmox. Ontwerp focust op eenvoud, segmentatie en geïntegreerde SIEM (Wazuh) met IDS (Suricata).

## 11. Aanbevolen vervolgstappen
- Diagrammen uitwerken (workflow en netwerk).
- Packer-template finaliseren en imagenaming/retentie vastleggen.
- Terraform-modules opschonen en variabiliseren (VLAN/bridges/VM-sizes).
- Ansible-rollen voor Wazuh/Suricata/monitoring opzetten.
- CI/CD-pipeline koppelen (lint/validate/build/test/deploy).

## Referenties
- Proxmox, Packer, Terraform, Ansible documentatie; interne SecLab-notities; repo: https://github.com/huy496334/IaC-project

---

## Bijlage A: Packer (Proxmox) skeleton
```hcl
packer {
  required_plugins {
    proxmox = { source = "github.com/hashicorp/proxmox" }
  }
}

variable "proxmox_url" {}
variable "proxmox_token" {}

source "proxmox-iso" "ubuntu" {
  proxmox_url    = var.proxmox_url
  token          = var.proxmox_token
  node           = "pve"
  iso_file       = "local:iso/ubuntu-22.04.iso"
  ssh_username   = "packer"
  ssh_password   = "packer"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]
  provisioner "shell" { inline = [
    "sudo apt-get update",
    "sudo apt-get -y upgrade",
  ]}
}
```

## Bijlage B: Terraform (Proxmox VM) skeleton
```hcl
terraform {
  required_providers { proxmox = { source = "telmate/proxmox" } }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "wazuh" {
  name        = "wazuh-01"
  target_node = "pve"
  clone       = var.golden_image_name
  cores = 2
  memory = 4096
  network { model = "virtio" bridge = "vmbr0" tag = 50 }
}
```

## Bijlage C: Ansible skeleton
```ini
# inventory.ini
[wazuh]
wazuh-01 ansible_host=192.168.50.10

[ids]
suricata-01 ansible_host=192.168.52.10
```
```yaml
# site.yml
- hosts: wazuh
  become: true
  roles: [wazuh]

- hosts: ids
  become: true
  roles: [suricata]
```

## Bijlage D: Pre-deploy checklist
- [ ] Secrets/ tokens via Vault klaar
- [ ] Netwerk (bridges/VLAN) aanwezig in Proxmox
- [ ] Golden image beschikbaar en getagd
- [ ] CI/CD checks groen (lint/validate)

## Bijlage E: Diagram placeholders
- Workflow Packer→Terraform→Ansible
- Netwerktekening (VLAN 50/52, datastromen)
