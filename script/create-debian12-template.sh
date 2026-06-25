#!/bin/bash
set -e

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

mkdir -p $ISO_DIR
cd $ISO_DIR

if [ ! -f "$IMG" ]; then
    wget -O "$IMG" "$URL"
fi

if qm status $VMID &>/dev/null; then
    qm stop $VMID || true
    qm destroy $VMID
fi

qm create $VMID \
  --name $VMNAME \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=$BRIDGE \
  --serial0 socket \
  --vga serial0

qm importdisk $VMID $IMG $STORAGE

qm set $VMID \
  --scsihw virtio-scsi-pci \
  --scsi0 $STORAGE:vm-$VMID-disk-0,discard=on,ssd=1

qm set $VMID --ide2 $STORAGE:cloudinit
qm set $VMID --boot order=scsi0 --agent enabled=1
qm set $VMID --ciuser $USERNAME --cipassword $PASSWORD --ipconfig0 ip=dhcp

mkdir -p /var/lib/vz/snippets

cat > /var/lib/vz/snippets/debian.yaml <<EOF
#cloud-config
hostname: debian-template
manage_etc_hosts: true
ssh_pwauth: true
disable_root: false

users:
    - name: $USERNAME
    groups: sudo
    shell: /bin/bash
    sudo: ALL=(ALL) ALL:ALL
    lock_passwd: false

chpasswd:
  list: |
    $USERNAME:$PASSWORD
#    root:$PASSWORD
  expire: false

package_update: true
packages:
    - qemu-guest-agent
    - openssh-server


runcmd:
    - sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    - sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
    - systemctl enable ssh
    - systemctl restart ssh
    - systemctl enable qemu-guest-agent
    - systemctl start qemu-guest-agent
    - cloud-init clean
EOF

qm set $VMID --cicustom "vendor=local:snippets/debian.yaml"
qm resize $VMID scsi0 20G

echo "Starting VM to run cloud-init..."
qm start $VMID
echo "Wait 45s for cloud-init to finish..."
sleep 45
qm shutdown $VMID --timeout 60

rm -f  /var/lib/vz/snippets/debian.yaml

echo "===================="
echo "TEMPLATE READY: $VMID"
echo "USER: $USERNAME"
echo "PASS: $PASSWORD"
echo ""
echo "Convert to template:"
echo "qm template $VMID"
echo ""
echo "Clone test:"
echo "qm clone $VMID 100 --name test-vm --full && qm start 100"
echo "===================="