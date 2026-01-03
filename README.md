# Golden Image for Proxmox

This repository contains documentation and helper files for creating and managing Proxmox VM templates using Ubuntu cloud images and cloud-init. Packer configs are retained for reference but the preferred workflow is:

- Import an Ubuntu cloud image into Proxmox and create a template.
- Use cloud-init for initial instance configuration (SSH keys, users).
- Use Ansible to perform post-clone configuration and package installation.

## Current config summary

- **Base Image**: Ubuntu 24.04 Noble Cloud Image
- **Storage**: local-lvm
- **Disk Format**: raw
- **CPU**: 2 cores
- **Memory**: 2048 MB
- **Cloud-init**: enabled

## Troubleshooting

# Golden Image for Proxmox (cloud-image + cloud-init)

This repository previously used Packer to build templates. Workflow has changed:

- We now use the official Ubuntu cloud image + cloud-init to create a Proxmox template.
- Packer configs remain in the repo for reference, but Packer is no longer required.

## Why switch

- Cloud images are lightweight, maintained by Ubuntu, and boot quickly.
- `cloud-init` provides deterministic, repeatable initial configuration.
- Creating a single template in Proxmox from the cloud image is a small, one-time operation; further customization is handled with Ansible.

## Quick workflow (one-time template creation)

1. Download the Ubuntu cloud image locally:

```bash
cd /tmp
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
```

2. (Optional) Convert to raw for `local-lvm`, or copy the QCOW2 directly. Proxmox's
`qm importdisk` can accept QCOW2 or RAW images, so conversion is not strictly required:

```bash
# optional: convert to raw
qemu-img convert -f qcow2 -O raw noble-server-cloudimg-amd64.img noble-server-cloudimg-amd64.raw
scp noble-server-cloudimg-amd64.raw root@<proxmox-host>:/root/

# or copy the original QCOW2 and import it directly on the Proxmox host
scp noble-server-cloudimg-amd64.img root@<proxmox-host>:/root/
```

3. On the Proxmox host, create a VM and import the disk:

```bash
# choose an available VMID, e.g. 9002
qm create 9002 --name ubuntu-cloud-base --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0
qm importdisk 9002 /root/noble-server-cloudimg-amd64.raw local-lvm
qm set 9002 --scsi0 local-lvm:vm-9002-disk-0
qm set 9002 --boot c --bootdisk scsi0
qm set 9002 --ide2 local:cloudinit
# Optional: set an initial cloud-init user/password or SSH key
qm set 9002 --ciuser ubuntu --cipassword <password>
# Convert to template
qm template 9002
```

After this you have a Proxmox template that can be cloned for deployments.

## Using cloud-init (seed files)

- Place your `user-data` and `meta-data` in a directory and use the Proxmox cloud-init drive or Packer/Ansible to provide the seed.
- Example `user-data` should set `ssh_authorized_keys` or a password, enable users, and install packages if desired.

## Ansible — next steps

We're switching customization to Ansible. Suggested next steps:

1. Create an `inventory/` directory and add host groups for your environments.
2. Add a `playbooks/` directory and create a `golden-image.yml` playbook to perform updates and enable `qemu-guest-agent` on cloned VMs.
3. Use `ansible-playbook -i inventory/hosts playbooks/golden-image.yml` to provision clones.

A minimal Ansible checklist (to add to the repo):

- `inventory/hosts` — host definitions
- `playbooks/golden-image.yml` — tasks: `apt update/upgrade`, install `qemu-guest-agent`, enable services, cleanup
- `roles/` — optionally split tasks into roles

## Example Ansible task snippet

```yaml
- name: Ensure qemu-guest-agent installed
	become: true
	apt:
		name: qemu-guest-agent
		state: present
		update_cache: yes

- name: Enable qemu-guest-agent
	become: true
	systemd:
		name: qemu-guest-agent
		enabled: yes
		state: started
```

## Notes

- If you want to fully automate the import process, you can script the `qm` commands or run them via a CI job that has SSH access to the Proxmox host.
- Keep secrets out of the repo; use Vault or CI secret storage for credentials.

## Resources

- Ubuntu Cloud Images: https://cloud-images.ubuntu.com/
- Proxmox `qm` manual: https://pve.proxmox.com/pve-docs/
- Ansible docs: https://docs.ansible.com/

---

If you want, I can add a starter `inventory/` and `playbooks/golden-image.yml` to this repo and create an initial Ansible playbook that performs the `apt` updates and installs `qemu-guest-agent`.
