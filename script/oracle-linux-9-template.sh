#!/bin/bash

set -euo pipefail

# ==========================
# CONFIG
# ==========================
VMID=9007
VMNAME="oracle-linux-9-template"

STORAGE="local-lvm"
BRIDGE="vmbr0"

IMAGE="Oracle-Linux-9.5-GenericCloud.qcow2"
URL="https://yum.oracle.com/templates/OracleLinux/OL9/u5/x86_64/${IMAGE}"

ISO_DIR="/var/lib/vz/template/iso"
IMG="${ISO_DIR}/${IMAGE}"

USERNAME="opc"
PASSWORD="Oracle123!"


# ==========================
# DOWNLOAD
# ==========================

mkdir -p ${ISO_DIR}

if [ ! -f "${IMG}" ]; then
    echo ">>> Download Oracle Linux Cloud Image"
    wget -O "${IMG}" "${URL}"
fi


# ==========================
# REMOVE OLD VM
# ==========================

if qm status ${VMID} >/dev/null 2>&1; then
    qm stop ${VMID} --skiplock || true
    qm destroy ${VMID} --purge
fi


# ==========================
# CREATE VM
# ==========================

qm create ${VMID} \
    --name ${VMNAME} \
    --memory 4096 \
    --cores 4 \
    --cpu host \
    --machine q35 \
    --ostype l26 \
    --agent enabled=1 \
    --serial0 socket \
    --vga serial0 \
    --net0 virtio,bridge=${BRIDGE}


# ==========================
# DISK
# ==========================

qm disk import ${VMID} ${IMG} ${STORAGE}


qm set ${VMID} \
    --scsihw virtio-scsi-single \
    --scsi0 ${STORAGE}:vm-${VMID}-disk-0,discard=on,iothread=1,ssd=1


# ==========================
# CLOUD INIT
# ==========================

qm set ${VMID} \
    --ide2 ${STORAGE}:cloudinit \
    --boot order=scsi0 \
    --ciuser ${USERNAME} \
    --cipassword "${PASSWORD}" \
    --ipconfig0 ip=dhcp



mkdir -p /var/lib/vz/snippets


cat > /var/lib/vz/snippets/oracle-${VMID}.yaml <<EOF
#cloud-config

hostname: oracle-linux-template

ssh_pwauth: true
disable_root: true

package_update: true

packages:
 - qemu-guest-agent
 - vim
 - curl
 - wget
 - htop
 - net-tools


runcmd:

 - systemctl enable qemu-guest-agent
 - systemctl start qemu-guest-agent

 - sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

 - systemctl restart sshd

 - cloud-init clean

EOF


qm set ${VMID} \
    --cicustom "vendor=local:snippets/oracle-${VMID}.yaml"


# ==========================
# RESIZE
# ==========================

qm resize ${VMID} scsi0 +30G


# ==========================
# START
# ==========================

qm start ${VMID}


echo
echo "================================"
echo "Oracle Linux Template Ready"
echo "VMID: ${VMID}"
echo "User: ${USERNAME}"
echo "Pass: ${PASSWORD}"
echo
echo "Convert:"
echo "qm template ${VMID}"
echo
echo "Clone:"
echo "qm clone ${VMID} 300 --name oracle-test --full"
echo "================================"