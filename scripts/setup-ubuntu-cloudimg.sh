#!/bin/bash

cd /var/lib/vz/template/iso

wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img

virt-customize -a /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img --install qemu-guest-agent

qm create 9002 --name "ubuntu-2404-cloudimg" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 &&
qm importdisk 9002 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img local-lvm &&
qm set 9002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9002-disk-0 &&
qm set 9002 --boot c --bootdisk scsi0 &&
qm set 9002 --scsi2 local-lvm:cloudinit &&
qm set 9002 --agent enabled=1 &&
qm template 9002
