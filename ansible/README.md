# Wazuh Ansible Deployment

Deploy Wazuh SIEM (all-in-one) using official Wazuh Ansible roles.

## Structure

```
ansible/
+-- ansible.cfg                 # Ansible configuration
+-- group_vars/
¦   +-- all.yml                 # SSH credentials and common vars
+-- inventory/
¦   +-- hosts.ini               # Target server (192.168.50.10)
+-- playbooks/
¦   +-- wazuh-aio.yml           # All-in-one deployment playbook
+-- roles/
    +-- wazuh-ansible/          # Official Wazuh roles (v4.14.1)
        +-- roles/wazuh/
            +-- wazuh-indexer/
            +-- wazuh-dashboard/
            +-- ansible-wazuh-manager/
            +-- ansible-filebeat-oss/
```

## Usage

1. Test connectivity:
   ```bash
   ansible wazuh_all_in_one -m ping
   ```

2. Run deployment:
   ```bash
   ansible-playbook playbooks/wazuh-aio.yml
   ```

## After Installation

- URL: https://192.168.50.10
- Username: admin
- Password: changeme (change this!)
