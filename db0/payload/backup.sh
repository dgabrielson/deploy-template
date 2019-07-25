#!/bin/bash

# Backup script for postgresql, designed to be run as a root cronjob.
# This script does NOT do anything fancy, e.g., rotate destinations
#   for keeping tiers of backups.
# https://www.commandprompt.com/blogs/joshua_drake/2010/07/a_better_backup_with_postgresql_using_pg_dump/

DST="/storage/backup/"   # backup destination, end with /
OWNER="CLUSTER_USER"

# change to a directory that both postgres and ${OWNER} can read:
cd "/tmp"

sudo -u postgres pg_dumpall -U postgres -g | sudo -u ${OWNER} tee "${DST}_globals_.sql" > /dev/null
sudo -u postgres psql -U postgres -At -c "SELECT datname FROM pg_database \
                          WHERE NOT datistemplate"| \
while read f; do
    sudo -u postgres pg_dump -U postgres --format=c ${f} | sudo -u ${OWNER} tee "${DST}${f}.sqlc" > /dev/null
done
