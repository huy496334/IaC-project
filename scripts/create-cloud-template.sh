#!/bin/bash
# Script to create Ubuntu Cloud Init template on Proxmox
# Run this script on the Proxmox host as root

set -e

# Configuration
TEMPLATE_ID=9002
TEMPLATE_NAME="ubuntu-cloud-init-template"
STORAGE_POOL="local-lvm"
CLOUD_IMAGE="/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img"
SNIPPETS_DIR="/var/lib/vz/snippets"
CLOUD_CONFIG="ubuntu-cloud-config.yml"

# Password hash
PASSWORD_HASH='$6$rounds=4096$YMT7afWS4ioHDhWv$gJrv/2bGcfdJT7KmV7.2CknXUwA5qCVa.oM420wtKsYArJNJCaVp9A3I.qN/ABwFkh17vEuT.i3gYF51HGNMr0'

echo "=== Creating Ubuntu Cloud Init Template ==="

# Create snippets directory if it doesn't exist
mkdir -p "$SNIPPETS_DIR"

# Create cloud-init config
echo "Creating cloud-init configuration..."
cat > "$SNIPPETS_DIR/$CLOUD_CONFIG" << EOF
#cloud-config
ssh_pwauth: true
chpasswd:
  expire: false
users:
  - name: ubuntu
    gecos: 'Ubuntu User'
    passwd: '$PASSWORD_HASH'
    groups: [sudo, adm]
    shell: /bin/bash
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
EOF

# Check if template already exists and destroy it
if qm status $TEMPLATE_ID &>/dev/null; then
    echo "Template $TEMPLATE_ID exists, destroying..."
    qm destroy $TEMPLATE_ID --purge
fi

# Check if cloud image exists
if [ ! -f "$CLOUD_IMAGE" ]; then
    echo "Cloud image not found. Downloading..."
    wget -O "$CLOUD_IMAGE" https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
fi

echo "Creating VM $TEMPLATE_ID..."
qm create $TEMPLATE_ID --name "$TEMPLATE_NAME" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

echo "Importing disk..."
qm importdisk $TEMPLATE_ID "$CLOUD_IMAGE" $STORAGE_POOL

echo "Configuring VM..."
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --ide2 $STORAGE_POOL:cloudinit
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent enabled=1
qm set $TEMPLATE_ID --ipconfig0 ip=dhcp
qm set $TEMPLATE_ID --cicustom "user=local:snippets/$CLOUD_CONFIG"

echo "Converting to template..."
qm template $TEMPLATE_ID

echo "=== Template $TEMPLATE_ID ($TEMPLATE_NAME) created successfully! ==="
echo ""
echo "You can now use this template with Terraform:"
echo "  template_id   = $TEMPLATE_ID"
echo "  template_name = \"$TEMPLATE_NAME\""
