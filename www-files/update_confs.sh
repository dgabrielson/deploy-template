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
    deploy.include_sudoers:../_nrpe/40_needrestart \
    deploy.putconf:../_nrpe/nagios_needrestart.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_needrestart.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_needrestart.sh' \
    deploy.nagios.nrpe:local_nrpe.cfg,update_conf=1 \
    deploy.nginx.enable_local_site:50_${NAME}.conf,nginx.conf

if [ -d "${DIR}" ]; then
    popd
fi
