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
    authorize_ssh
    
# Mail accounts:
rsync -auv accounts  ${DEPLOY_ADMIN}@${FQDN}:
    
fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${FQDN} \
    `# use vdb for mail data` \
    sudo:'/sbin/pvcreate /dev/vdb' \
    sudo:'/sbin/vgcreate data /dev/vdb' \
    `# 20G = 5120 extents -- lv overhead takes one` \
    sudo:'/sbin/lvcreate -l 5119 -n mail data' \
    sudo:'mkfs.ext4 -v -m .01 -b 4096 -L maildata  /dev/data/mail' \
    sudo:'mkdir -p /var/mail' \
    sudo:'mount /dev/data/mail /var/mail' \
    sudo:'echo "LABEL\=maildata  /var/mail   ext4    defaults    0   1" >> /etc/fstab' \
    `# end setup of separate maildata volume` \
    deploy.set_hostname:"${FQDN}" \
    deploy.linux:root_alias=${ROOT_EMAIL} \
    deploy.putconf:../_nrpe/nagios_needrestart.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_needrestart.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_needrestart.sh' \
    deploy.nagios.nrpe:local_nrpe.cfg \
    deploy.postfix.flurdy:origin="${MAIL_ORIGIN}",relay="${MAIL_RELAY}",relay_auth="${MAIL_RELAY_AUTH}",relay_auth_mechanism="${MAIL_RELAY_AUTH_MECHANISM}",masq_domains="${MAIL_MASQ_DOMAINS}",allow_subnet="${MAIL_ALLOW_SUBNET}" \
    sudo:'cd accounts && make all'

# reconfigure what was done before::
# (This is now fixed in all settings.sh files.)
# fab -f ${MGMT_FABFILE} -H ${PREV_HOST_LIST} \
#     sudo:'sed -i~ 's/^root:/#root:/g' /etc/aliases' \
#     deploy.linux:"root_alias=${ROOT_EMAIL}" \
#     deploy.postfix.satellite:"relay=${FQDN}:25,mailname=${DOMAIN}"


if [ -d "${DIR}" ]; then
    popd
fi
