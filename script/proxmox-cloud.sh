#!/bin/bash

set -e


# ================= CONFIG =================

VMID=9000
VMNAME="ubuntu-22-LTS"

STORAGE="local-lvm"
BRIDGE="vmbr0"


IMAGE="jammy-server-cloudimg-amd64.img"
URL="https://cloud-images.ubuntu.com/jammy/current/$IMAGE"


ISO_DIR="/var/lib/vz/template/iso"
IMG="$ISO_DIR/$IMAGE"

SNIPPET_DIR="/var/lib/vz/snippets"


USERNAME="ubuntu"
PASSWORD="12345678"



# ================= PREP =================

mkdir -p $ISO_DIR
mkdir -p $SNIPPET_DIR



# ================= DOWNLOAD =================

if [ ! -f "$IMG" ]; then

echo ">>> Download Ubuntu 22.04"

wget -O "$IMG" "$URL"

fi



# ================= REMOVE OLD =================

if qm status $VMID &>/dev/null
then

echo ">>> Remove old VM"

qm stop $VMID || true

qm destroy $VMID --purge

fi



# ================= CREATE VM =================


echo ">>> Create VM"


qm create $VMID \
--name $VMNAME \
--memory 2048 \
--cores 2 \
--cpu host \
--ostype l26 \
--net0 virtio,bridge=$BRIDGE \
--serial0 socket \
--vga serial0 \
--agent enabled=1




# ================= IMPORT DISK =================


echo ">>> Import disk"


qm importdisk $VMID $IMG $STORAGE





# ================= DISK =================


qm set $VMID \
--scsihw virtio-scsi-single \
--scsi0 $STORAGE:vm-$VMID-disk-0,discard=on,iothread=1




# ================= CLOUD INIT =================


qm set $VMID \
--ide2 $STORAGE:cloudinit


qm set $VMID \
--boot order=scsi0





# ================= CLOUD CONFIG =================


echo ">>> Create cloud-init"



cat > $SNIPPET_DIR/ubuntu-22-LTS.yaml <<EOF

#cloud-config


ssh_pwauth: true


package_update: true


packages:

 - qemu-guest-agent
 - openssh-server



runcmd:

 - systemctl enable qemu-guest-agent
 - systemctl start qemu-guest-agent

 - systemctl enable ssh
 - systemctl start ssh


EOF





# ================= APPLY CLOUD INIT =================


echo ">>> Apply cloud-init"



qm set $VMID \
--cicustom "user=local:snippets/ubuntu-22-LTS.yaml"



qm set $VMID \
--ciuser "$USERNAME" \
--cipassword "$PASSWORD" \
--ipconfig0 ip=dhcp \
--nameserver "1.1.1.1 8.8.8.8"





# ================= RESIZE =================


qm resize $VMID scsi0 20G




# ================= FIRST BOOT =================


echo ">>> Start VM"

qm start $VMID



echo ">>> Waiting cloud-init"

sleep 120





# ================= CLEAN =================


#qm stop $VMID || true


# Remove machine identity for clones

#qm set $VMID --delete ciuser,cipassword || true



# Convert template

#qm template $VMID





echo ""
echo "================================"
echo " UBUNTU 22 TEMPLATE READY"
echo ""
echo " VMID : $VMID"
echo " USER : $USERNAME"
echo " PASS : $PASSWORD"
echo ""
echo "Clone:"
echo "qm clone $VMID 100 --name test --full"
echo "================================"