#!/bin/bash
set -euo pipefail

# ==========================
# CONFIG
# ==========================
VMID=9004
VMNAME="almalinux-9-template"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="AlmaLinux-9-GenericCloud-latest.x86_64.qcow2"
URL="https://repo.almalinux.org/almalinux/9/cloud/x86_64/images/${IMAGE}"

ISO_DIR="/var/lib/vz/template/iso"
SNIPPET_DIR="/var/lib/vz/snippets"

IMG="$ISO_DIR/$IMAGE"

USERNAME="almalinux"
PASSWORD="12345678"


# ==========================
# PREPARE
# ==========================

mkdir -p "$ISO_DIR"
mkdir -p "$SNIPPET_DIR"


if [ ! -s "$IMG" ]; then
    echo ">>> Download AlmaLinux 9 image"
    rm -f "$IMG"
    wget -O "$IMG" "$URL"
fi


qemu-img info "$IMG" >/dev/null


# remove old VM

if qm status $VMID >/dev/null 2>&1; then
    echo ">>> Remove old VM"
    qm stop $VMID || true
    qm destroy $VMID --purge
fi



# ==========================
# CREATE VM
# ==========================

echo ">>> Creating VM"

qm create $VMID \
 --name "$VMNAME" \
 --memory 2048 \
 --cores 2 \
 --cpu host \
 --ostype l26 \
 --net0 virtio,bridge=$BRIDGE \
 --serial0 socket \
 --vga serial0 \
 --agent enabled=1



# ==========================
# IMPORT DISK
# ==========================

echo ">>> Import disk"

qm importdisk $VMID "$IMG" $STORAGE



# ==========================
# DISK CONFIG
# ==========================

qm set $VMID \
 --scsihw virtio-scsi-single \
 --scsi0 $STORAGE:vm-$VMID-disk-0,discard=on,iothread=1



# ==========================
# CLOUD INIT
# ==========================

qm set $VMID \
 --ide2 $STORAGE:cloudinit \
 --boot order=scsi0



cat > "$SNIPPET_DIR/alma-$VMID.yaml" <<EOF
#cloud-config

ssh_pwauth: true

users:
  - default

package_update: true
package_upgrade: false

packages:
 - qemu-guest-agent
 - openssh-server
 - curl
 - vim
 - htop
 - net-tools


runcmd:

 - systemctl enable qemu-guest-agent
 - systemctl start qemu-guest-agent

 - systemctl enable sshd
 - systemctl start sshd

EOF



# IMPORTANT
# user not vendor

qm set $VMID \
 --cicustom "vendor=local:snippets/alma-$VMID.yaml"



qm set $VMID \
 --ciuser "$USERNAME" \
 --cipassword "$PASSWORD" \
 --ipconfig0 ip=dhcp



# ==========================
# RESIZE
# ==========================

echo ">>> Resize disk"

qm resize $VMID scsi0 20G



# ==========================
# START FIRST BOOT
# ==========================

echo ">>> Start VM"

qm start $VMID


echo ">>> Waiting cloud-init"

sleep 120



# ==========================
# CHECK AGENT
# ==========================

qm agent $VMID ping || true



# ==========================
# CLEAN
# ==========================

#echo ">>> Shutdown"

#qm shutdown $VMID --timeout 120 || true


while qm status $VMID | grep -q running
do
 sleep 5
done



# ==========================
# TEMPLATE
# ==========================

#echo ">>> Convert template"

#qm template $VMID



echo ""
echo "================================="
echo " AlmaLinux 9 Template READY"
echo ""
echo " VMID : $VMID"
echo " USER : $USERNAME"
echo " PASS : $PASSWORD"
echo ""
echo "Clone:"
echo "qm clone $VMID 100 --name alma-test"
echo "================================="