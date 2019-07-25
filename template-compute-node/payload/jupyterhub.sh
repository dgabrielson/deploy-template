#!/bin/bash
# An service script for the JupyterHub Service

set -e
LOGFILE=/var/log/gauss/jupyterhub.log
LOGDIR=$(dirname $LOGFILE)
LOGLEVEL="INFO" # DEBUG/INFO/WARNING/ERROR/CRITICAL

# user/group to run as
USER="root"

test -d $LOGDIR || mkdir -p $LOGDIR

touch "${LOGFILE}"
chown ${USER} "${LOGFILE}"

exec su ${USER} -c \
    ". /usr/local/share/jupyterhub/bin/activate && \
    /usr/local/share/jupyterhub/bin/jupyterhub \
    -f /etc/jupyterhub/jupyterhub_config.py
    2>>${LOGFILE} \
    "
