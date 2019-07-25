#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"

VOLUME_NAME="storage"
VOLUME_ROOT="/storage"
VOLUME_SIZE="100G"
