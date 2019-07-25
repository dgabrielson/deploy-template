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


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${TARGET_PUBLIC_IP} \
    `# NRPE - Nagios monitoring` \
    deploy.nagios.nrpe:local_nrpe.cfg,update_conf=1 \
    deploy.add_hosts:../hosts.extra \
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
    dscm.update:mgmt-fab \
    dscm.update:stats-deploy \
    deploy.putconf:vm-backup.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/vm-backup.sh' \
    sudo:'chmod +x /usr/local/sbin/vm-backup.sh'
    
    
ssh -t ${DEPLOY_ADMIN}@${TARGET_PUBLIC_IP} '( for h in kvm1 kvm2 provision; do ./stats-deploy/${h}/update_confs.sh; done )'



if [ -d "${DIR}" ]; then
    popd
fi
