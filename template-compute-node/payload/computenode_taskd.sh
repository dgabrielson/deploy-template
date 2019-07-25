#!/bin/bash
# A script for the eparch compute node task daemon

set -e
LOGFILE=/var/log/gauss/computenode_taskd.log
LOGDIR=$(dirname $LOGFILE)
LOGLEVEL="INFO" # DEBUG/INFO/WARNING/ERROR/CRITICAL

# user/group to run as
USER=root

# The socket owner/group should match the euid/egid of computenode_poll,
#   *and* be as restrictive as possible.
SOCKET_OWNER='www-data'
SOCKET_GROUP='root'

VENV_PATH="/usr/local/share/gauss/"
PROJECT_PATH="${VENV_PATH}bin/"

source "${VENV_PATH}bin/activate"
cd "${PROJECT_PATH}"

test -d $LOGDIR || mkdir -p $LOGDIR

touch "${LOGFILE}"
chown ${USER} "${LOGFILE}"

exec su ${USER} -c \
    "./taskd.py --owner ${SOCKET_OWNER} --group ${SOCKET_GROUP} \
    >${LOGFILE} 2>&1
    "
