#!/bin/bash
# Setup script for Wazuh Ansible deployment
# Run this from the ansible directory

set -e

WAZUH_ANSIBLE_VERSION="v4.14.1"

echo "=== Wazuh Ansible Setup ==="
echo ""

# Check if we're in the right directory
if [ ! -f "ansible.cfg" ]; then
    echo "Error: Please run this script from the ansible directory"
    exit 1
fi

# Create roles directory if it doesn't exist
mkdir -p roles

# Clone or update wazuh-ansible
if [ -d "roles/wazuh-ansible" ]; then
    echo "Updating wazuh-ansible roles..."
    cd roles/wazuh-ansible
    git fetch origin
    git checkout $WAZUH_ANSIBLE_VERSION
    cd ../..
else
    echo "Cloning wazuh-ansible repository (version $WAZUH_ANSIBLE_VERSION)..."
    git clone --branch $WAZUH_ANSIBLE_VERSION https://github.com/wazuh/wazuh-ansible.git roles/wazuh-ansible
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Available roles:"
ls -la roles/wazuh-ansible/roles/wazuh/
echo ""
echo "Next steps:"
echo "1. Test connectivity: ansible wazuh_all_in_one -m ping"
echo "2. Run the playbook: ansible-playbook playbooks/wazuh-aio.yml"
echo ""
echo "Default credentials after installation:"
echo "  URL: https://192.168.50.10"
echo "  User: admin"
echo "  Password: changeme"
