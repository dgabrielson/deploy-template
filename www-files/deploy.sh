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
    deploy.postfix.satellite:relay=${MAIL_RELAY},mailname=${DOMAIN} \
    deploy.linux:root_alias=${ROOT_EMAIL} \
    deploy.include_sudoers:../_nrpe/40_needrestart \
    deploy.putconf:../_nrpe/nagios_needrestart.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_needrestart.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_needrestart.sh' \
    deploy.nagios.nrpe:local_nrpe.cfg \
    deploy.rsyslog.client:"${LOGHOST}" \
    `# install application` \
    deploy.nginx.install \
    deploy.nfs_client:${NFSCLIENT} \
    `# configure application` \
    deploy.nginx.disable_site:default \
    deploy.nginx.enable_local_site:50_${NAME}.conf,nginx.conf 



if [ -d "${DIR}" ]; then
    popd
fi
