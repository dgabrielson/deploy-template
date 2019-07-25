#!/bin/bash
set -e

DIR="${BASH_SOURCE%/*}"
if [ -d "${DIR}" ]; then
    pushd "${DIR}"
fi
source "./settings.sh"


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${DBFQDN} \
    `# setup database` \
    deploy.postgresql.createuser:"${DBUSER},${DBPASS}" \
    deploy.postgresql.grant_host_access:"${DBNAME},${DBUSER},${DBCLIENTADDR}"


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${NFSFQDN} \
    `# setup NFS storage` \
    sudo:"mkdir -p ${NFSHOSTPATH}/html/{static\,media}" \
    sudo:"chown -R ${DEPLOY_ADMIN}:www-data ${NFSHOSTPATH}/html" \
    sudo:"chmod -R a+rX ${NFSHOSTPATH}/html" \
    sudo:"chmod -R g+w ${NFSHOSTPATH}/html/media"


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${FQDN} \
    authorize_ssh \
    deploy.set_hostname:"${FQDN}" \
    deploy.postfix.satellite:"relay=${MAIL_RELAY},mailname=${DOMAIN}" \
    deploy.linux:"root_alias=${ROOT_EMAIL}" \
    sudo:'mkdir -p /var/www/empty' 
    


if [ -d "${DIR}" ]; then
    popd
fi
