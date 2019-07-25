#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"


MAIL_ORIGIN="${DOMAIN}"
MAIL_RELAY="smtp.ad.example.com"
MAIL_RELAY_AUTH="mailuser:password"
MAIL_RELAY_AUTH_MECHANISM="plain login"
MAIL_MASQ_DOMAINS="${FQDN}"
MAIL_ALLOW_SUBNET="1"
# These should be set and transferred to the remote in deploy and update_confs.
# MAIL_CERT_FILE=""
# MAIL_KEY_FILE=""
# MAIL_CERT_FILE=""


