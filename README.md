# SOC Lab Infrastructure-as-Code

Compleet Security Operations Center lab gebouwd met Terraform (infrastructuur) en Ansible (configuratiebeheer). Implementeert een multi-VM-omgeving met Wazuh SIEM, Suricata IDS, Zabbix monitoring, GLPI ticketing, T-Pot honeypot en Infection Monkey pentest framework.

**Status**: ✅ Wazuh, Suricata, Zabbix, Grafana, GLPI, T-Pot, Infection Monkey allemaal operationeel

## Infrastructuur Overzicht

### Architectuur

```
┌─────────────────────────────────────────────────────────────────┐
│                     Proxmox 7.0+                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │   Router     │  │ Wazuh Server │  │  Suricata    │           │
│  │  (NAT/VLAN)  │  │ (All-in-one) │  │  IDS (v8.0)  │           │
│  │  VLAN 50     │  │  VLAN 50     │  │  VLAN 50     │           │
│  │ 192.168.50.1 │  │ 192.168.50.10│  │ 192.168.50.11│           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐           │
│  │  Zabbix +    │  │    GLPI      │  │   T-Pot      │           │
│  │  Grafana     │  │  Ticketing   │  │  Honeypot    │           │
│  │  VLAN 50     │  │  VLAN 50     │  │  VLAN 52     │           │
│  │ 192.168.50.20│  │ 192.168.50.30│  │ 192.168.52.10│           │
│  └──────────────┘  └──────────────┘  └──────────────┘           │
│                                                                   │
│  ┌──────────────┐                                               │
│  │  Infection   │                                               │
│  │  Monkey      │                                               │
│  │  VLAN 50     │                                               │
│  │ 192.168.50.40│                                               │
│  └──────────────┘                                               │
└─────────────────────────────────────────────────────────────────┘
```

### Geïmplementeerde VMs

| VM | IP | Doel | CPU | RAM | Schijf | Status |
|---|---|---|---|---|---|---|
| router | 192.168.50.1 | NAT gateway, VLAN bridge, DNS | 2 | 2GB | 20GB | ✅ Actief |
| wazuh-server | 192.168.50.10 | Wazuh indexer + dashboard + manager | 2 | 6GB | **100GB** | ✅ Actief |
| suricata-ids | 192.168.50.11 | Network IDS (v8.0.2) | 1 | 1GB | 20GB | ✅ Actief |
| zabbix-grafana | 192.168.50.20 | Monitoring & visualisatie | 2 | 2GB | 20GB | ✅ Actief |
| glpi-tickets | 192.168.50.30 | IT ticketing systeem | 1 | 1GB | 20GB | ✅ Actief |
| tpot-honeypot | 192.168.52.10 | Honeypot (geïsoleerde VLAN 52) | 2 | 2GB | 40GB | ✅ Actief |
| infection-monkey | 192.168.50.40 | Pentest/breach simulatie | 1 | 1GB | 20GB | ✅ Actief |

## Snelle Start

De implementatie bestaat uit **3 hoofdstappen**:

1. **setup-ubuntu-cloudimg.sh**: Maak de Ubuntu cloud image template in Proxmox
2. **Terraform**: Implementeer alle 7 VMs met netwerken
3. **Ansible**: Installeer en configureer alle applicaties

### Vereisten

- Proxmox 7.0+ met netwerktogang en SSH toegang
- Terraform 1.0+
- Ansible 2.13+
- SSH sleutelpaar (`~/.ssh/id_ed25519`)
- `curl` en `git` geïnstalleerd

### Voorbereidende Configuratie

#### 1. Genereer SSH Key Pair (als je dat nog niet hebt)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
```

Dit maakt een Ed25519 sleutelpaar aan zonder passphrase. De openbare sleutel wordt automatisch naar je Proxmox VMs gestuurd via cloud-init.

#### 2. Maak terraform.tfvars

Kopieer de example file en pas deze aan met je Proxmox instellingen:

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Vul je Proxmox configuratie in:

```hcl
proxmox_url             = "https://your-proxmox-host:8006"
proxmox_api_token_id    = "terraform@pam!terraform"
proxmox_api_token_secret = "your-api-token-secret"
proxmox_node            = "pve"
```

**Hoe je Proxmox API token aanmaakt:**

1. Log in op Proxmox web interface
2. Ga naar Datacenter → Permissions → API Tokens
3. Klik "Add"
4. Vul in: User = `terraform@pam`, Token ID = `terraform`
5. Zet "Privilege Separation" uit
6. Kopieer het Token en sla het op in terraform.tfvars

Voor meer details, zie de officiële documentatie:
[Terraform Proxmox Provider Documentation](https://registry.terraform.io/providers/Terraform-for-Proxmox/proxmox/latest/docs)

### Stap 1: Maak Ubuntu Cloud Image Template

```bash
cd /home/huy/Documents/IaC-project
bash setup-ubuntu-cloudimg.sh
```

Dit script:
- Downloadt de officiële Ubuntu 24.04 cloud image
- Importeert het in Proxmox
- Maakt een herbruikbare template aan

### Stap 2: Implementeer Infrastructuur (Terraform)

```bash
cd /home/huy/Documents/IaC-project
terraform init
terraform plan
terraform apply -auto-approve
```

Dit maakt alle 7 VMs aan:
- Router (NAT gateway)
- Wazuh server (100GB schijf)
- Suricata IDS
- Zabbix + Grafana
- GLPI ticketing
- T-Pot honeypot
- Infection Monkey

Met juiste networking, storage en cloud-init configuratie.

### Stap 3: Configureer met Ansible

```bash
cd ansible/playbooks

# Verifieer dat alle hosts bereikbaar zijn
ansible all -i ../inventory/hosts.ini -m ping
```

**Optie A: Voer alle playbooks tegelijk uit**

```bash
./run-all-playbooks.sh
```

**Optie B: Voer playbooks individueel uit**

```bash
# Implementeer Wazuh (indexer + dashboard + manager + filebeat)
ansible-playbook wazuh-indexer-and-dashboard.yml -i ../inventory/hosts.ini -b -K
ansible-playbook wazuh-manager-oss.yml -i ../inventory/hosts.ini -b -K

# Implementeer Suricata IDS
ansible-playbook suricata-install.yml -i ../inventory/hosts.ini -b -K

# Implementeer Zabbix + Grafana
ansible-playbook zabbix-grafana-install.yml -i ../inventory/hosts.ini -b -K

# Implementeer overige services
ansible-playbook glpi-install.yml -i ../inventory/hosts.ini -b -K
ansible-playbook tpot-install.yml -i ../inventory/hosts.ini -b -K
ansible-playbook infection-monkey-install.yml -i ../inventory/hosts.ini -b -K
```

### Workflow Samenvatting

```
setup-ubuntu-cloudimg.sh
        ↓
    Terraform
        ↓
      Ansible
        ↓
   SOC Lab Ready ✅
```

## Component Details

### Wazuh Security Platform (v4.7.0)

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

- **Indexer** (OpenSearch): 9200, 9600
- **Dashboard**: HTTPS, zelf-ondertekend certificaat, standaard poort 443
- **Manager**: Kern monitoring engine
- **Filebeat**: Agent → indexer pipeline
- **Standaard Creds**: `admin` / `changeme` (onmiddellijk wijzigen)

**Toegang**:
```
https://192.168.50.10:443/app/wazuh
```

**Belangrijkste Functies**:
- Realtime dreigingsdetectie
- Logboekaggregatie & analyse
- Compliance rapportage (PCI-DSS, CIS, etc.)
- 100GB schijf voor logboeken (onlangs uitgebreid van 20GB)

### Suricata IDS (v8.0.2)

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

- **Modus**: Network IDS op eth1
- **Logging**: EVE JSON formaat
- **Regels**: Community regels ingeschakeld
- **Geheugen**: ~37MB

**Belangrijkste Functies**:
- Netwerkverkeerscontrole
- TLS fingerprinting
- DNS logging
- SSL/TLS certificaatextractie

### Zabbix 7.0 + Grafana

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

**Zabbix Componenten**:
- Server: Monitoring engine
- Frontend: Web dashboard (http://192.168.50.20/zabbix)
- Agent: Host metrics collectie
- Database: MySQL met Zabbix schema

**Grafana**:
- Poort: 3000
- Dashboard visualisatie & alerting
- Standaard: `admin` / `admin`

**Geplande Functies**:
- VM CPU/Memory/Disk monitoring
- Wazuh integratie
- Alert drempels & meldingen

### GLPI Ticketing

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

- IT Service Management
- Ticket tracking & resolutie
- Asset inventaris
- Knowledge base

### T-Pot Honeypot

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

- Geïsoleerde honeypot omgeving (VLAN 52)
- Meerdere honeypot engines (Cowrie, Dionaea, Suricata)
- Aanvalsverzameling & analyse

### Infection Monkey

**Status**: ✅ GEÏMPLEMENTEERD & OPERATIONEEL

- Geautomatiseerde penetratie testen
- Laterale bewegingssimulatie
- Kwetsbaarheidsscanning
- Beveiligingspostuuranalyse

## Bestandsstructuur

```
/home/huy/Documents/IaC-project/
├── LICENSE
├── README.md (dit bestand)
├── main.tf                          # Terraform hoofdconfig
├── vms.tf                           # VM definities (7 VMs)
├── variables.tf                     # Terraform variabelen
├── packer.pkr.hcl                   # Packer config (legacy, referentie)
├── ansible/
│   └── wazuh-ansible-4.14.1/
│       ├── inventory/
│       │   └── hosts.ini            # Ansible inventaris
│       └── playbooks/
│           ├── ansible.cfg          # Ansible configuratie
│           ├── wazuh-indexer-and-dashboard.yml
│           ├── wazuh-manager-oss.yml
│           ├── suricata-install.yml
│           ├── zabbix-grafana-install.yml
│           ├── glpi-install.yml
│           ├── tpot-install.yml
│           ├── infection-monkey-install.yml
│           └── run-all-playbooks.sh
└── .git/                            # Git repository
```

## Implementatiestatus

### ✅ Voltooid

- **Git**: Repository geïnitialiseerd en gesynchroniseerd
- **Terraform**: Alle 7 VMs aangemaakt met juiste networking
- **Netwerk**: VLANs (50, 52), NAT, DNS, routing geconfigureerd
- **Wazuh**: Indexer + Dashboard + Manager + Filebeat (allemaal actief)
- **Suricata**: v8.0.2 IDS operationeel
- **Ansible**: Inventaris geconfigureerd, SSH geverifieerd, host key checking ingeschakeld
- **Schijf Uitbreiding**: Wazuh server uitgebreid van 20GB naar 100GB
- **Zabbix**: v7.0 met Grafana volledig geïmplementeerd
- **GLPI**: Ticketing systeem operationeel
- **T-Pot**: Honeypot omgeving actief
- **Infection Monkey**: Pentest framework ingesteld

### 🔧 In Afwachting

- Aanvullende functies en integraties (aangepaste dashboards, geavanceerde alerting, etc.)

## Probleemoplossing

### VM connectiviteitsproblemen

Controleer SSH connectiviteit:
```bash
ssh -i ~/.ssh/id_ed25519 ubuntu@192.168.50.10
```

Verifieer Ansible:
```bash
ansible all -i ansible/wazuh-ansible-4.14.1/inventory/hosts.ini -m ping
```

### Wazuh toegangsproblemen

Controleer servicestatus:
```bash
ssh ubuntu@192.168.50.10
sudo systemctl status wazuh-indexer wazuh-manager wazuh-dashboard
```

Stel wachtwoord opnieuw in (indien nodig):
```bash
# Op wazuh-server
sudo -u wazuh /usr/share/wazuh/scripts/wazuh-password-tool.sh -u admin -p newpassword
```

### Schijfruimte op wazuh-server

Controleer huidigegebruik:
```bash
ssh ubuntu@192.168.50.10 df -h
```

Wis oude logboeken indien nodig:
```bash
ssh ubuntu@192.168.50.10 sudo journalctl --vacuum=100M
```

### Ansible SSH-sleutel problemen

Zorg ervoor dat sleutel geladen is:
```bash
ssh-add ~/.ssh/id_ed25519
ssh-agent -l
```

Controleer ansible.cfg op juist sleutelpad:
```bash
grep private_key_file ansible/wazuh-ansible-4.14.1/playbooks/ansible.cfg
```

## Veiligheidsopmerkingen

⚠️ **Standaard Inloggegevens**: Onmiddellijk wijzigen in productie

- Wazuh: `admin` / `changeme`
- Grafana: `admin` / `admin`
- Zabbix: `admin` / `zabbix`
- MySQL: `zabbix` / `zabbix123`

⚠️ **SSL Certificaten**: Zelf-ondertekend, installeer juiste certificaten voor productie

⚠️ **Firewall**: Lab omgeving heeft permissieve regels; beperk in productie

## Volgende Stappen

1. Configureer monitoring en alerting
2. Maak beveiligingsdashboards
3. Implementeer logboekbewaaringsbeleid
4. Stel geautomatiseerde back-ups in
5. Integreer externe dreigingsinformatie
6. Voer regelmatige penetratietests uit

## Bronnen

- **Terraform**: https://registry.terraform.io/providers/Telmate/proxmox/latest
- **Wazuh**: https://documentation.wazuh.com/
- **Suricata**: https://suricata.io/
- **Zabbix**: https://www.zabbix.com/documentation/
- **Grafana**: https://grafana.com/docs/
- **Ansible**: https://docs.ansible.com/
- **Ubuntu Cloud Images**: https://cloud-images.ubuntu.com/
