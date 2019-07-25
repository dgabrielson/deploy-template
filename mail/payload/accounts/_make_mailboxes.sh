#!/bin/bash

if [ -f accounts.cf ]; then
  # Creating users
  # 'pass' is encrypted
  while IFS=$'|' read login pass
  do
    # Setting variables for better readability
    user=$(echo ${login} | cut -d @ -f1)
    domain=$(echo ${login} | cut -d @ -f2)
    # Let's go!
    echo "user '${user}' for domain '${domain}' with password '********'"
    mkdir -p /var/mail/${domain}
    if [ ! -d "/var/mail/${domain}/${user}" ]; then
      maildirmake.dovecot "/var/mail/${domain}/${user}"
      maildirmake.dovecot "/var/mail/${domain}/${user}/.Sent"
      maildirmake.dovecot "/var/mail/${domain}/${user}/.Trash"
      maildirmake.dovecot "/var/mail/${domain}/${user}/.Drafts"
      echo -e "INBOX\nSent\nTrash\nDrafts" >> "/var/mail/${domain}/${user}/subscriptions"
      touch "/var/mail/${domain}/${user}/.Sent/maildirfolder"
    fi
    # Copy user provided sieve file, if present
    test -e ${login}.dovecot.sieve && cp ${login}.dovecot.sieve /var/mail/${domain}/${user}/.dovecot.sieve
    chown -R virtual:virtual "/var/mail/${domain}/${user}"
  done < accounts.cf
else
  echo "==> Warning: 'accounts.cf' is not provided. No mail account created."
fi


