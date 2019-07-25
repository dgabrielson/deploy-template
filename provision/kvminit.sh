#!/bin/bash
set -e 

# The build system makes a settings.mk copy which is bash source-able.
source settings.mk

# Only use this technique for initializing the VM when the
# VM has special requirements, i.e., non-standard but initially required options.

# The Provision VM needs to be installed without any PXE!
PRESEED_URL="http://130.179.75.65/~gabriels/example-preseed.cfg"
UBUNTU_RELEASE="16.04.2"
ISO_BASENAME="ubuntu-${UBUNTU_RELEASE}-server-amd64.iso"
ISO_URL="http://releases.ubuntu.com/${UBUNTU_RELEASE}/${ISO_BASENAME}"
ARGS_SERIAL="text console=tty0 console=ttyS0,115200"
ARGS_PRESEED="auto=true preseed/url=${PRESEED_URL} netcfg/choose_interface=ens2 netcfg/get_hostname=${NAME}"
EXTRA_ARGS="${ARGS_PRESEED} --- ${ARGS_SERIAL} "
DISK_IMG=/var/local/disks/${NAME}.qcow2

# Retreive the ISO, if we don't have it.
if [ ! -f "${ISO_BASENAME}" ]; then
    wget "${ISO_URL}"
fi

# Ensure default network comes up, and we know what our IP will be.
virsh net-autostart default
if ! virsh net-dumpxml default | grep ${NAME}; then
    virsh net-update default add ip-dhcp-host \
        "<host mac='${DEFAULT_NET_MACADDR}' name='${NAME}' ip='${DEFAULT_NET_IP}' />" \
        --live --config
fi    


if [ ! -f "${DISK_IMG}" ]; then
/usr/bin/qemu-img create -f qcow2 -o preallocation=off \
     ${DISK_IMG} ${DISK}G
fi

if ! virsh list --all --name | grep ${NAME}; then
    virt-install --name=${NAME} --ram=${MEMORY} \
        --disk=path=${DISK_IMG},format=qcow2,bus=virtio,cache=none \
        --network=network=default,mac=$DEFAULT_NET_MACADDR \
        --network=bridge=br1,mac=$MACADDR \
        --vcpus=${CPU_COUNT} --os-variant=virtio26 --location="${ISO_BASENAME}" \
        --graphics none \
        --extra-args="${EXTRA_ARGS}"
fi

virsh autostart ${NAME}


