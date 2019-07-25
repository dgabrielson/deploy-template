#!/bin/bash

#
# Users
#
if [ -f accounts.cf ]; then
  echo -n > postfix_virtual_mailboxmaps
  echo -n > dovecot_userdb

  # Creating users
  # 'pass' is encrypted
  while IFS=$'|' read login pass
  do
    # Setting variables for better readability
    user=$(echo ${login} | cut -d @ -f1)
    domain=$(echo ${login} | cut -d @ -f2)
    # Let's go!
    echo "user '${user}' for domain '${domain}' with password '********'"
    echo "${login} ${domain}/${user}/" >> postfix_virtual_mailboxmaps
    # User database for dovecot has the following format:
    # user:password:uid:gid:(gecos):home:(shell):extra_fields
    # Example :
    # ${login}:${pass}:5000:5000::/var/mail/${domain}/${user}::userdb_mail=maildir:/var/mail/${domain}/${user}
    echo "${login}:${pass}:5000:5000::/var/mail/${domain}/${user}::" >> dovecot_userdb
    echo ${domain} >> vhost.tmp
  done < accounts.cf
else
  echo "==> Warning: 'accounts.cf' is not provided. No mail account created."
fi


#
# Aliases
#
if [ -f aliases.cf ]; then
  # Copying virtual file
  cp aliases.cf postfix_virtual_aliasmaps
  while read from to
  do
    # Setting variables for better readability
    uname=$(echo ${from} | cut -d @ -f1)
    domain=$(echo ${from} | cut -d @ -f2)
    # if they are equal it means the line looks like: "user1     other@domain.tld"
    test "$uname" != "$domain" && echo ${domain} >> vhost.tmp
  done < aliases.cf
else
  echo "==> Warning: 'aliases.cf' is not provided. No mail alias/forward created."
  touch postfix_virtual_aliasmaps
fi
if [ -f regexp.cf ]; then
  # Copying regexp alias file
  echo "Adding regexp alias file regexp.cf"
  cp regexp.cf postfix_virtual_aliasmaps_regexp
else
    touch postfix_virtual_aliasmaps_regexp
fi

if [ -f vhost.tmp ]; then
  cat vhost.tmp | sort | uniq > postfix_virtual_domains && rm vhost.tmp
fi

# echo "Postfix configurations"
# touch postfix_virtual_mailboxmaps && postmap postfix_virtual_mailboxmaps
# touch postfix_virtual_aliasmaps && postmap postfix_virtual_aliasmaps
