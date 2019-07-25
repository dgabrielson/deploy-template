#!/bin/bash

# Fabric bash functions

function mgmt-fabric-role()
{
    local role="$1"
    local status
    shift 1
    workon fab
    fab -R "${role}" "$@"
    status=$?
    deactivate
    cd - > /dev/null
    return $status
}


function mgmt-fabric-host()
{
    local host="$1"
    local status
    shift 1
    workon fab
    fab -H "${host}" "$@"
    status=$?
    deactivate
    cd - > /dev/null
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
