#!/bin/bash

# Fabric bash functions

VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
# Ubuntu 16.04
if [ -f /etc/bash_completion.d/virtualenvwrapper ]; then
    source /etc/bash_completion.d/virtualenvwrapper
fi

FABFILE="~/mgmt-fab/fabfile"


function mgmt-fabric-role()
{
    local role="$1"
    local status
    shift 1
    workon fab
    fab -f "${FABFILE}" -R "${role}" "$@"
    status=$?
    deactivate
    if [[ -n "${OLDPWD}" ]]; then
        cd - > /dev/null
    fi
    return $status
}


function mgmt-fabric-host()
{
    local host="$1"
    local status
    shift 1
    workon fab
    fab -f "${FABFILE}" -H "${host}" "$@"
    status=$?
    deactivate
    if [[ -n "${OLDPWD}" ]]; then
        cd - > /dev/null
    fi
    return $status
}


function fab-update
{
    mgmt-fabric-role all softwareupdate
}

function fab-safeupdate
{
    mgmt-fabric-role virt softwareupdate && \
    mgmt-fabric-role phys softwareupdate:allow_reboot=False
}
