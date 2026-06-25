#!/bin/bash
set -euo pipefail


VMID=9002
VMNAME="debian-12-template"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="debian-12-genericcloud-amd64.qcow2"
URL="https://cloud.debian.org/images/cloud/bookworm/latest/$IMAGE"

ISO_DIR="/var/lib/vz/template/iso"
IMG="$ISO_DIR/$IMAGE"

USERNAME="debian"
PASSWORD="12345678"

SNIPPET="/var/lib/vz/snippets/debian-$VMID.yaml"


mkdir -p "$ISO_DIR"
mkdir -p /var/lib/vz/snippets


if [ ! -f "$IMG" ]; then
 echo "Downloading Debian image..."
 wget -O "$IMG" "$URL"
fi


if qm status $VMID &>/dev/null; then
 qm stop $VMID || true
 qm destroy $VMID --purge
fi


qm create $VMID \
 --name $VMNAME \
 --memory 2048 \
 --cores 2 \
 --cpu host \
 --net0 virtio,bridge=$BRIDGE \
 --serial0 socket \
 --vga serial0 \
 --ostype l26 \
 --agent enabled=1


qm importdisk $VMID $IMG $STORAGE


qm set $VMID \
 --scsihw virtio-scsi-single \
 --scsi0 $STORAGE:vm-$VMID-disk-0,discard=on,ssd=1,iothread=1


qm set $VMID \
 --ide2 $STORAGE:cloudinit \
 --boot order=scsi0


cat > $SNIPPET <<EOF

#cloud-config

hostname: debian-template

ssh_pwauth: true

users:
  - name: default
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    plain_text_passwd: $PASSWORD


packages:
 - qemu-guest-agent
 - curl
 - vim
 - htop


runcmd:
 - systemctl enable qemu-guest-agent
 - systemctl start qemu-guest-agent
 - sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
 - systemctl restart ssh

EOF


qm set $VMID \
 --cicustom vendor=local:snippets/debian-$VMID.yaml


qm set $VMID \
 --ciuser $USERNAME \
 --cipassword "$PASSWORD" \
 --ipconfig0 ip=dhcp \
# --nameserver "1.1.1.1 8.8.8.8"


qm resize $VMID scsi0 20G


qm start $VMID


echo "Waiting boot..."
sleep 120


qm guest exec $VMID -- cloud-init clean --logs || true
qm guest exec $VMID -- truncate -s 0 /etc/machine-id || true


qm shutdown $VMID --timeout 120 || true


while qm status $VMID | grep -q running
do
 sleep 5
done


qm template $VMID


echo "============================"
echo "Debian Template READY"
echo "VMID: $VMID"
echo "USER: $USERNAME"
echo "PASS: $PASSWORD"
echo "============================"