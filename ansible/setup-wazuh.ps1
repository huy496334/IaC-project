# Setup script for Wazuh Ansible deployment (Windows PowerShell)
# Run this from the ansible directory

$ErrorActionPreference = "Stop"

$WAZUH_ANSIBLE_VERSION = "v4.14.1"

Write-Host "=== Wazuh Ansible Setup ===" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "ansible.cfg")) {
    Write-Host "Error: Please run this script from the ansible directory" -ForegroundColor Red
    exit 1
}

# Create roles directory if it doesn't exist
if (-not (Test-Path "roles")) {
    New-Item -ItemType Directory -Path "roles" | Out-Null
}

# Clone or update wazuh-ansible
if (Test-Path "roles/wazuh-ansible") {
    Write-Host "Updating wazuh-ansible roles..." -ForegroundColor Yellow
    Push-Location "roles/wazuh-ansible"
    git fetch origin
    git checkout $WAZUH_ANSIBLE_VERSION
    Pop-Location
} else {
    Write-Host "Cloning wazuh-ansible repository (version $WAZUH_ANSIBLE_VERSION)..." -ForegroundColor Yellow
    git clone --branch $WAZUH_ANSIBLE_VERSION https://github.com/wazuh/wazuh-ansible.git roles/wazuh-ansible
}

Write-Host ""
Write-Host "=== Setup Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Available roles:" -ForegroundColor Cyan
Get-ChildItem "roles/wazuh-ansible/roles/wazuh/" | Format-Table Name
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Test connectivity: ansible wazuh_all_in_one -m ping"
Write-Host "2. Run the playbook: ansible-playbook playbooks/wazuh-aio.yml"
Write-Host ""
Write-Host "Default credentials after installation:" -ForegroundColor Yellow
Write-Host "  URL: https://192.168.50.10"
Write-Host "  User: admin"
Write-Host "  Password: changeme"
