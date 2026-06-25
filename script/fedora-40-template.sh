#!/bin/bash

set -euo pipefail

# ==========================
# CONFIG
# ==========================
VMID=9003
VMNAME="fedora-40-template"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="Fedora-Cloud-Base-Generic-40-1.14.x86_64.qcow2"
URL="https://download.fedoraproject.org/pub/fedora/linux/releases/40/Cloud/x86_64/images/${IMAGE}"

ISO_DIR="/var/lib/vz/template/iso"
IMG="${ISO_DIR}/${IMAGE}"

USERNAME="fedora"
PASSWORD="12345678"

# ==========================
# DOWNLOAD IMAGE
# ==========================
mkdir -p "${ISO_DIR}"

if [ ! -f "${IMG}" ]; then
    echo ">>> Downloading Fedora 40 Cloud Image..."
    wget -O "${IMG}" "${URL}"
fi

# ==========================
# REMOVE EXISTING VM
# ==========================
if qm status ${VMID} >/dev/null 2>&1; then
    echo ">>> Removing existing VM ${VMID}"
    qm stop ${VMID} --skiplock || true
    qm destroy ${VMID} --purge
fi

# ==========================
# CREATE VM
# ==========================
echo ">>> Creating VM ${VMID}"

qm create ${VMID} \
    --name "${VMNAME}" \
    --memory 2048 \
    --cores 2 \
    --cpu host \
    --machine q35 \
    --ostype l26 \
    --agent enabled=1 \
    --serial0 socket \
    --vga serial0 \
    --net0 virtio,bridge=${BRIDGE}

# ==========================
# IMPORT DISK
# ==========================
echo ">>> Importing disk"

qm importdisk ${VMID} "${IMG}" ${STORAGE}

qm set ${VMID} \
    --scsihw virtio-scsi-single \
    --scsi0 ${STORAGE}:vm-${VMID}-disk-0,discard=on,iothread=1,ssd=1

# ==========================
# CLOUD INIT DRIVE
# ==========================
qm set ${VMID} \
    --ide2 ${STORAGE}:cloudinit \
    --boot order=scsi0 \
    --ciuser "${USERNAME}" \
    --cipassword "${PASSWORD}" \
    --ipconfig0 ip=dhcp

# ==========================
# CUSTOM CLOUD-INIT
# ==========================
mkdir -p /var/lib/vz/snippets

cat > /var/lib/vz/snippets/fedora-${VMID}.yaml <<EOF
#cloud-config

hostname: fedora-template
manage_etc_hosts: true

ssh_pwauth: true
disable_root: true

chpasswd:
  expire: false

packages:
  - qemu-guest-agent
  - curl
  - wget
  - vim
  - htop
  - net-tools

runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl start qemu-guest-agent
  - sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  - systemctl restart sshd
EOF

qm set ${VMID} \
    --cicustom "vendor=local:snippets/fedora-${VMID}.yaml"

# ==========================
# RESIZE DISK
# ==========================
qm resize ${VMID} scsi0 +20G

# ==========================
# START VM
# ==========================
echo ">>> Starting VM"

qm start ${VMID}

echo
echo "======================================="
echo "VM Created Successfully"
echo "VMID     : ${VMID}"
echo "Name     : ${VMNAME}"
echo "User     : ${USERNAME}"
echo "Password : ${PASSWORD}"
echo
echo "Convert to template:"
echo "qm template ${VMID}"
echo
echo "Clone:"
echo "qm clone ${VMID} 101 --name fedora-test --full"
echo "======================================="