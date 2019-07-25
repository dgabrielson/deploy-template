#!/bin/bash
set -e

DIR="${BASH_SOURCE%/*}"
if [ -d "${DIR}" ]; then
    pushd "${DIR}"
fi
source "./settings.sh"

if [ -n "${VIRTUAL_ENV}" ]; then
    PATH="$VIRTUAL_ENV/bin:$PATH"
    unset PYTHON_HOME
fi


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${FQDN} \
    `# core setup` \
    authorize_ssh \
    deploy.set_hostname:"${FQDN}" \
    deploy.postfix.satellite:"relay=${MAIL_RELAY},mailname=${DOMAIN}" \
    deploy.linux:"root_alias=${ROOT_EMAIL}" \
    deploy.rsyslog.client:"${LOGHOST}" \
    `# setup auxiliary interfaces with redirection` \
    deploy.putconf:"payload/dhclient.conf,/etc/dhcp/" \
    deploy.network_interfaces.add_dhcp_interface:"eth1" \
    sudo:"ifup eth1" \
    deploy.nginx.disable_site:"default" \
    sudo:'mkdir -p /var/www/empty' \
    sudo:'mkdir -p /var/www/ssl' 
    
    

if [ -d "${DIR}" ]; then
    popd
fi
