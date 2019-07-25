#!/bin/bash
# An Ubuntu/Upstart script for the Eparch Compute Node Poll Service

set -e
LOGFILE=/var/log/gauss/computenode_poll.log
LOGDIR=$(dirname $LOGFILE)
LOGLEVEL="INFO" # DEBUG/INFO/WARNING/ERROR/CRITICAL

# user/group to run as
USER="root"

test -d $LOGDIR || mkdir -p $LOGDIR

touch "${LOGFILE}"
chown ${USER} "${LOGFILE}"

# django-admin bootstraps virtual environment.
exec su ${USER} -c \
    "/usr/local/sbin/django-admin eparch computenode_poll --repeat \
    2>>${LOGFILE} \
    "
