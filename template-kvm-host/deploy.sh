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


# Assuming Debian install with root user, $DEPLOY_ADMIN user; dhcp eth0

## ssh as user account
#su 
## enter root password
#apt-get update
#apt-get upgrade
#apt-get install  sudo
#adduser $DEPLOY_ADMIN sudo


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${TARGET_PUBLIC_IP} \
    `# core setup` \
    sudo:'passwd -l root' \
    sudo:"sed -i.bak 's/^PermitRootLogin without-password/PermitRootLogin no/g' /etc/ssh/sshd_config" \
    authorize_ssh \
    deploy.postfix.satellite:relay=${MAIL_RELAY},mailname=${TARGET_DOMAIN} \
    deploy.linux:root_alias=reports@example.com \
    deploy.smartmontools \
    deploy.include_sudoers:../_nrpe/30_check-smartmon \
    deploy.putconf:../_nrpe/nagios_check_smartmon.py,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_check_smartmon.py' \
    sudo:'chmod +x /usr/local/sbin/nagios_check_smartmon.py' \
    deploy.putconf:../_nrpe/nagios_check_mdstat.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_check_mdstat.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_check_mdstat.sh' \
    deploy.include_sudoers:../_nrpe/40_needrestart \
    deploy.putconf:../_nrpe/nagios_needrestart.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_needrestart.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_needrestart.sh' \
    deploy.nagios.nrpe:local_nrpe.cfg \
    `#deploy.rsyslog.client:"${LOGHOST}"` \
    `# resize home ` \
    `# create new lv for vm disks` \
    `# disable eth0` \
    `# setup bridge(s)` \
    `#deploy.set_hostname:kvm0.example.com,br1` \
    deploy.add_hosts:skaro_hosts.txt \
    `#deploy.add_hosts:../hosts.extra` \
    dscm.clone:'ssh://dave@home.CLUSTER_USERon.ca/stats-mgmt-fab,mgmt-fab' \
    dscm.clone:'ssh://dave@home.CLUSTER_USERon.ca/stats-deploy,stats-deploy' \
    deploy.putconf:vm-backup.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/vm-backup.sh' \
    sudo:'chmod +x /usr/local/sbin/vm-backup.sh' \
    sudo:'mkdir /var/local/disks/backup/' \
    deploy.add_cronjob:'0 1 * * * /usr/local/sbin/vm-backup.sh /var/local/disks/backup/',user=root \
    deploy.kvm.install \
    deploy.pyenv.prep:minimal=True \
    deploy.pyenv.create:fab,fab_requirements.txt,local=True \
    deploy.glusterfs_client:"${GLUSTERFS_CLIENT}" \
    deploy.nfs_server:"${NFS_EXPORT}"


if [ -d "${DIR}" ]; then
    popd
fi
