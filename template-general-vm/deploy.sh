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
    authorize_ssh \
    deploy.set_hostname:"${FQDN}" \
    deploy.postfix.satellite:"relay=${MAIL_RELAY},mailname=${DOMAIN}" \
    deploy.linux:"root_alias=${ROOT_EMAIL}" \
    deploy.nagios.nrpe:local_nrpe.cfg 


if [ -d "${DIR}" ]; then
    popd
fi
