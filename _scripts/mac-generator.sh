#!/bin/bash
MD5="$(which md5sum)"
if [ -z ${MD5} ]; then
    MD5="$(which md5)"
fi
if [ -z ${MD5} ]; then
    echo "Could not locate an md5 command."
    exit 1
fi
MACADDR="52:54:00:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | ${MD5} | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"
echo ${MACADDR}