#!/usr/bin/env bash
set -e

MGMT_FABFILE=$1
DEPLOY_ADMIN=$2
DOMAIN=$3
IP_ADDRESS=$4
INPUT_FILENAME=$5


# Two levels of stdin here; one for read; one for fab
# See: https://stackoverflow.com/a/41652573

exec 3</dev/tty || exec 3<&0 

while read -rs database dbuser dbpass extra; do
    #database="$(echo ${line} | cut -f 1 -d ' ')"
    #dbuser="$(echo ${line} | cut -f 2 -d ' ')"
    #dbpass="$(echo ${line} | cut -f 3 -d ' ')"
    if [[ "${database:0:1}" != "#" && -n ${database} ]]; then
        echo db:${database}	user:${dbuser}	pass:${dbpass}
        fab -f ${MGMT_FABFILE} -u ${DEPLOY_ADMIN} -H db0.${DOMAIN} \
                deploy.postgresql.createuser:"${dbuser},${dbpass}" \
                deploy.postgresql.createdb:"${database},${dbuser}" \
                deploy.postgresql.grant_host_access:"${database},${dbuser},${IP_ADDRESS}/32" \
		<&3 
    fi
done < "${INPUT_FILENAME}"

exec 3<&- 
