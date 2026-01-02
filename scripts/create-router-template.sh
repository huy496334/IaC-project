#!/bin/bash
# Script to create Ubuntu Router template on Proxmox
# This boots the VM, configures NAT, then converts to template
# Run this script on the Proxmox host as root

set -e

# Configuration
TEMPLATE_ID=9003
TEMPLATE_NAME="ubuntu-router-template"
STORAGE_POOL="local-lvm"
CLOUD_IMAGE="/var/lib/vz/template/iso/noble-server-cloudimg-amd64.img"
SNIPPETS_DIR="/var/lib/vz/snippets"

# Password hash for 'Proxmox10022000'
PASSWORD_HASH='$6$rounds=4096$YMT7afWS4ioHDhWv$gJrv/2bGcfdJT7KmV7.2CknXUwA5qCVa.oM420wtKsYArJNJCaVp9A3I.qN/ABwFkh17vEuT.i3gYF51HGNMr0'

echo "=== Creating Ubuntu Router Template ==="

# Create snippets directory
mkdir -p "$SNIPPETS_DIR"

# Create initial cloud-init config (just for first boot setup)
cat > "$SNIPPETS_DIR/router-init.yml" << EOF
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
  - iptables-persistent
EOF

# Check if template/VM already exists and destroy it
if qm status $TEMPLATE_ID &>/dev/null; then
    echo "VM $TEMPLATE_ID exists, destroying..."
    qm stop $TEMPLATE_ID --skiplock 2>/dev/null || true
    qm destroy $TEMPLATE_ID --purge
fi

# Check if cloud image exists
if [ ! -f "$CLOUD_IMAGE" ]; then
    echo "Cloud image not found. Downloading..."
    wget -O "$CLOUD_IMAGE" https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
fi

echo "Creating VM $TEMPLATE_ID..."
qm create $TEMPLATE_ID --name "$TEMPLATE_NAME" --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0

echo "Importing disk..."
qm importdisk $TEMPLATE_ID "$CLOUD_IMAGE" $STORAGE_POOL

echo "Configuring VM..."
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE_POOL:vm-$TEMPLATE_ID-disk-0
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --ide2 $STORAGE_POOL:cloudinit
qm set $TEMPLATE_ID --serial0 socket --vga serial0
qm set $TEMPLATE_ID --agent enabled=1
qm set $TEMPLATE_ID --ipconfig0 ip=dhcp
qm set $TEMPLATE_ID --cicustom "user=local:snippets/router-init.yml"

echo "Starting VM for configuration..."
qm start $TEMPLATE_ID

echo "Waiting for VM to boot and cloud-init to complete (this may take 2-3 minutes)..."
sleep 30

# Wait for qemu-agent to respond
echo "Waiting for QEMU agent..."
for i in {1..60}; do
    if qm agent $TEMPLATE_ID ping 2>/dev/null; then
        echo "QEMU agent is responding!"
        break
    fi
    echo "  Waiting... ($i/60)"
    sleep 5
done

# Get the VM's IP address
echo "Getting VM IP address..."
VM_IP=$(qm agent $TEMPLATE_ID network-get-interfaces | grep -oP '"ip-address"\s*:\s*"\K192\.168\.[0-9]+\.[0-9]+' | head -1)

if [ -z "$VM_IP" ]; then
    # Try to get any IP
    VM_IP=$(qm agent $TEMPLATE_ID network-get-interfaces | grep -oP '"ip-address"\s*:\s*"\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | grep -v "127.0.0.1" | head -1)
fi

echo "VM IP: $VM_IP"

echo "Configuring router via SSH..."

# Configure the router
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@$VM_IP << 'ENDSSH'
# Wait for cloud-init to finish
sudo cloud-init status --wait

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-router.conf
echo "net.ipv6.conf.all.forwarding=1" | sudo tee -a /etc/sysctl.d/99-router.conf
sudo sysctl -p /etc/sysctl.d/99-router.conf

# Create NAT setup script
sudo tee /usr/local/bin/setup-nat.sh << 'SCRIPT'
#!/bin/bash
# Setup NAT for router - WAN is first interface (ens18)
WAN_IF="ens18"

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Flush existing rules
iptables -t nat -F
iptables -F FORWARD

# NAT masquerade on WAN
iptables -t nat -A POSTROUTING -o $WAN_IF -j MASQUERADE

# Allow forwarding from LAN interfaces
iptables -A FORWARD -i ens19 -o $WAN_IF -j ACCEPT
iptables -A FORWARD -i ens20 -o $WAN_IF -j ACCEPT

# Allow established connections back
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# Inter-VLAN routing (optional)
iptables -A FORWARD -i ens19 -o ens20 -j ACCEPT
iptables -A FORWARD -i ens20 -o ens19 -j ACCEPT

# Save rules
netfilter-persistent save 2>/dev/null || iptables-save > /etc/iptables/rules.v4

echo "NAT setup complete!"
SCRIPT

sudo chmod +x /usr/local/bin/setup-nat.sh

# Create systemd service
sudo tee /etc/systemd/system/setup-nat.service << 'SERVICE'
[Unit]
Description=Setup NAT and IP forwarding
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-nat.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
SERVICE

# Enable the service
sudo systemctl daemon-reload
sudo systemctl enable setup-nat.service

# Run it now to test
sudo /usr/local/bin/setup-nat.sh

# Clean up for templating
sudo cloud-init clean
sudo truncate -s 0 /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo rm -f /etc/ssh/ssh_host_*

echo "Router configuration complete!"
ENDSSH

echo "Shutting down VM..."
qm shutdown $TEMPLATE_ID
sleep 10

# Wait for VM to stop
for i in {1..30}; do
    STATUS=$(qm status $TEMPLATE_ID | grep -oP 'status: \K\w+')
    if [ "$STATUS" = "stopped" ]; then
        break
    fi
    echo "  Waiting for shutdown... ($i/30)"
    sleep 2
done

# Force stop if still running
qm stop $TEMPLATE_ID 2>/dev/null || true
sleep 2

echo "Converting to template..."
qm template $TEMPLATE_ID

# Clean up the init snippet (no longer needed, config is baked in)
rm -f "$SNIPPETS_DIR/router-init.yml"

echo ""
echo "=== Router Template $TEMPLATE_ID ($TEMPLATE_NAME) created successfully! ==="
echo ""
echo "The template has these features baked in:"
echo "  - IP forwarding enabled"
echo "  - NAT masquerading on ens18 (WAN)"
echo "  - Forwarding rules for ens19/ens20 (LAN)"
echo "  - setup-nat.service runs on every boot"
echo ""
echo "Use in Terraform:"
echo "  router_template_name = \"$TEMPLATE_NAME\""
