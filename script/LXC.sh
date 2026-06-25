#!/bin/bash

# ==========================
# LXC CONFIG
# ==========================

VMID=101
HOSTNAME="ubuntu22-lxc"
TEMPLATE="local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"

STORAGE="local-lvm"
DISK="10"
RAM="2048"
CORES="2"
PASSWORD="StrongPassword123!"

# Network
BRIDGE="vmbr0"
IP="dhcp"


# ==========================
# CHECK TEMPLATE
# ==========================

if [ ! -f "/var/lib/vz/template/cache/ubuntu-22.04-standard_22.04-1_amd64.tar.zst" ]; then
    echo "Downloading Ubuntu template..."
    pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
fi


# ==========================
# CREATE LXC
# ==========================

pct create $VMID $TEMPLATE \
--hostname $HOSTNAME \
--storage $STORAGE \
--rootfs $STORAGE:$DISK \
--memory $RAM \
--cores $CORES \
--net0 name=eth0,bridge=$BRIDGE,ip=$IP \
--password $PASSWORD \
--unprivileged 1 \
--features nesting=1


# ==========================
# START
# ==========================

pct start $VMID


echo "====================="
echo "LXC CREATED"
echo "VMID: $VMID"
echo "HOST: $HOSTNAME"
echo "USER: root"
echo "PASS: $PASSWORD"
echo "====================="