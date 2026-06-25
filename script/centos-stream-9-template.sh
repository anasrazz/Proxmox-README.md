#!/bin/bash

set -euo pipefail

# ==========================
# CONFIG
# ==========================
VMID=9005
VMNAME="centos-stream-9-template"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="CentOS-Stream-GenericCloud-9-latest.x86_64.qcow2"
URL="https://cloud.centos.org/centos/9-stream/x86_64/images/${IMAGE}"

ISO_DIR="/var/lib/vz/template/iso"
IMG="${ISO_DIR}/${IMAGE}"

USERNAME="cloud-user"
PASSWORD="ChangeMe123!"

# ==========================
# PREPARE
# ==========================
mkdir -p "${ISO_DIR}"

if [ ! -f "${IMG}" ]; then
    echo ">>> Downloading CentOS Stream 9 cloud image..."
    wget -O "${IMG}" "${URL}"
fi

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
echo ">>> Importing disk..."

qm importdisk ${VMID} "${IMG}" ${STORAGE}

qm set ${VMID} \
    --scsihw virtio-scsi-single \
    --scsi0 ${STORAGE}:vm-${VMID}-disk-0,discard=on,iothread=1,ssd=1

# ==========================
# CLOUD INIT
# ==========================
qm set ${VMID} \
    --ide2 ${STORAGE}:cloudinit \
    --boot order=scsi0 \
    --ciuser "${USERNAME}" \
    --cipassword "${PASSWORD}" \
    --ipconfig0 ip=dhcp

# ==========================
# CLOUD-INIT CUSTOM CONFIG
# ==========================
mkdir -p /var/lib/vz/snippets

cat > /var/lib/vz/snippets/centos-${VMID}.yaml <<EOF
#cloud-config

ssh_pwauth: true
disable_root: true

package_update: true

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
  - cloud-init clean
EOF

qm set ${VMID} \
    --cicustom "vendor=local:snippets/centos-${VMID}.yaml"

# ==========================
# RESIZE DISK
# ==========================
qm resize ${VMID} scsi0 +20G

# ==========================
# START VM
# ==========================
echo ">>> Starting VM..."

qm start ${VMID}

echo
echo "=========================================="
echo "Template VM Created"
echo "VMID      : ${VMID}"
echo "Name      : ${VMNAME}"
echo "Username  : ${USERNAME}"
echo "Password  : ${PASSWORD}"
echo
echo "Convert to template:"
echo "qm template ${VMID}"
echo
echo "Clone:"
echo "qm clone ${VMID} 101 --name centos-test --full"
echo "=========================================="