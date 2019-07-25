#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"

VOLUME_NAME="storage"
VOLUME_ROOT="/storage"
VOLUME_SIZE="100G"

STORAGE_ROOT="${VOLUME_ROOT}"
STORAGE_NET="192.168.75.0/24"
NFSD_OPTS="(rw\,sync\,no_subtree_check\,root_squash)"

NFS_SERVER="${STORAGE_ROOT} ${STORAGE_NET}${NFSD_OPTS}"

