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



fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${DBFQDN} \
    `# setup database` \
    deploy.postgresql.createuser:"${DBUSER},${DBPASS}" \
    deploy.postgresql.createdb:"${DBNAME},${DBUSER}" \
    deploy.postgresql.grant_host_access:"${DBNAME},${DBUSER},${DBCLIENTADDR}"


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${NFSFQDN} \
    `# setup NFS storage` \
    sudo:"mkdir -p ${NFSHOSTPATH}/html/{static\,media}" \
    sudo:"chown -R ${DEPLOY_ADMIN}:www-data ${NFSHOSTPATH}/html" \
    sudo:"chmod -R a+rX ${NFSHOSTPATH}/html" \
    sudo:"chmod -R g+w ${NFSHOSTPATH}/html/media"


fab -f ${MGMT_FABFILE} -H ${DEPLOY_ADMIN}@${FQDN} \
    authorize_ssh \
    deploy.set_hostname:${FQDN} \
    deploy.postfix.satellite:relay=${MAIL_RELAY},mailname=${DOMAIN} \
    deploy.linux:root_alias=${ROOT_EMAIL} \
    deploy.include_sudoers:../_nrpe/40_needrestart \
    deploy.putconf:../_nrpe/nagios_needrestart.sh,/usr/local/sbin/ \
    sudo:'chown root:root /usr/local/sbin/nagios_needrestart.sh' \
    sudo:'chmod +x /usr/local/sbin/nagios_needrestart.sh' \
    deploy.nagios.nrpe:local_nrpe.cfg \
    deploy.rsyslog.client:"${LOGHOST}" \
    deploy.nfs_client:${NFSCLIENT} \
    deploy.putconf:index.html,/storage/html/index.html,use_sudo=False \
    `# install application stack (uWSGI + Django)` \
    deploy.uwsgi.install \
    deploy.pyenv.prep \
    deploy.pyenv.localpypi:"${PYPI}" \
    `# configure application stack - virtualenv` \
    sudo:'apt-get install imagemagick texlive-full' \
    deploy.pyenv.create:${NAME},requirements.txt,local=True \
    `# configure application stack - Django` \
    deploy.putconf:django-settings.json,/etc/${NAME}-settings.json \
    django.migrate:virtualenv_path=~/.virtualenvs/${NAME},manage_cmd=manage.py \
    django.collectstatic:virtualenv_path=~/.virtualenvs/${NAME},manage_cmd=manage.py \
    `# configure application stack - uWSGI` \
    sudo:'mkdir -p /var/www/empty' \
    deploy.uwsgi.enable_local_app:${NAME}.ini,uwsgi.ini \
    run:'mkdir ~/bin' \
    deploy.putconf:'manage.sh,./bin/,use_sudo=False' \
    run:'chmod u+x ./bin/manage.sh' \
    deploy.crontab:'crontab.txt'

    


if [ -d "${DIR}" ]; then
    popd
fi
