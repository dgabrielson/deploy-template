#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"

MACADDR0="52:54:00:97:99:70"

