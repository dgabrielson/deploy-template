#!/bin/bash
NAME="<shortname>"
# needs to be resolvable by the installer environment
PRESEED_URL="http://192.168.0.151/media/preseed.cfg"
# needs to be a local file on the VM host.
INSTALL_ISO="ubuntu-14.04.3-server-amd64.iso"
# You can pre-allocated MACs by assigning directly
MACADDR="$(../mac-generator.sh)"
# RAM in megabytes
RAM="1024"
# DISK in gigabytes
DISK="20"
CPUS="4"
ARGS_SERIAL="text console=tty0 console=ttyS0,115200"
ARGS_PRESEED="auto=true preseed/url=${PRESEED_URL} netcfg/get_hostname=${NAME}"
EXTRA_ARGS="${ARGS_SERIAL} ${ARGS_PRESEED}"
sudo virt-install --name=${NAME} --ram=${RAM} \
--disk=path=/var/local/disks/${NAME}.raw,format=raw,size=${DISK},bus=virtio,cache=none \
--network=network=default \
--network=bridge=br1,mac=$MACADDR \
--vcpus=${CPUS} --os-variant=virtio26 --location="${INSTALL_ISO}" \
--extra-args="${EXTRA_ARGS}"
