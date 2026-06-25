#!/bin/bash

set -e

# ==========================
# CONFIG
# ==========================
VMID=9000
VMNAME="ubuntu-22-LTS"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="noble-server-cloudimg-amd64.img"
URL="https://cloud-images.ubuntu.com/noble/current/$IMAGE"

ISO_DIR="/var/lib/vz/template/iso"
IMG="$ISO_DIR/$IMAGE"

USERNAME="ubuntu"
PASSWORD="12345678"


# ==========================
# Download Image
# ==========================

mkdir -p $ISO_DIR

if [ ! -f "$IMG" ]; then
    wget -O $IMG $URL
fi


# ==========================
# Create VM
# ==========================

qm create $VMID \
--name $VMNAME \
--memory 2048 \
--cores 2 \
--net0 virtio,bridge=$BRIDGE \
--serial0 socket \
--vga serial0


# ==========================
# Import Disk
# ==========================

qm importdisk $VMID $IMG $STORAGE


qm set $VMID \
--scsihw virtio-scsi-pci \
--scsi0 $STORAGE:vm-$VMID-disk-0


# ==========================
# Cloud Init
# ==========================

qm set $VMID \
--ide2 $STORAGE:cloudinit


qm set $VMID \
--boot order=scsi0


qm set $VMID \
--ciuser $USERNAME \
--cipassword $PASSWORD \
--ipconfig0 ip=dhcp


# ==========================
# SSH KEY
# ==========================

#if [ -f /root/.ssh/id_rsa.pub ]; then

#qm set $VMID \
#--sshkeys /root/.ssh/id_rsa.pub

#fi


# ==========================
# QEMU Agent
# ==========================

qm set $VMID \
--agent enabled=1


# ==========================
# Cloud-init install packages
# ==========================

cat > /var/lib/vz/snippets/ubuntu-22-LTS.yaml <<EOF
#cloud-config

packages:
 - qemu-guest-agent
 - openssh-server

runcmd:

 - systemctl enable ssh
 - systemctl enable qemu-guest-agent

 - systemctl start ssh
 - systemctl start qemu-guest-agent

EOF


qm set $VMID \
--cicustom "vendor=local:snippets/ubuntu-22-LTS.yaml"



# ==========================
# Resize
# ==========================

qm resize $VMID scsi0 20G


# ==========================
# Start
# ==========================

qm start $VMID


echo "==============================="
echo "VM $VMID created"
echo ""
echo "Console:"
echo "qm terminal $VMID"
echo ""
echo "After boot:"
echo "qm agent $VMID ping"
echo ""
echo "Convert template:"
echo "qm shutdown $VMID"
echo "qm template $VMID"
echo "==============================="