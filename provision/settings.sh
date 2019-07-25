#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"

DEFAULT_NET_IP="192.168.122.10"
DEFAULT_NET_MACADDR="52:54:00:dd:63:00"
MGMT_NET="192.168.1.0/24"
