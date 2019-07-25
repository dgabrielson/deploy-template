#!/bin/bash

source ../common_settings.sh

NAME="$(basename $(../_scripts/realpath.sh .))"
FQDN="${NAME}.${DOMAIN}"

DBUSER="template-app"
DBNAME="template"
DBPASSWD='<random>'

