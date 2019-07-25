.DEFAULT_GOAL := help
.PHONY: help all mailboxes postfix-reload dovecot-reload clean postfix-local-clean dovecot-local-clean
HELP_COL_WIDTH=16


help:   ## Show this help message
	@grep -E '^\S+.*##.*' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_COL_WIDTH)s\033[0m %s\n", $$1, $$2}'


all: mailboxes postfix-reload dovecot-reload	## Setup mailserver domains, users, and aliases

clean: postfix-local-clean dovecot-local-clean	## Clean up local configs (not live ones)
	rm -f *~

accounts.cf: 
	touch $@  
	# fix line endings      
	sed -i~ -e 's/\r//g' accounts.cf
	# ensure trailing newline
	sed -i~ -e '$a\' accounts.cf

aliases.cf:
	touch $@  

regexp.cf:
	touch $@  

dovecot_userdb: accounts.cf
	bash _build_virtual.sh

postfix_virtual_aliasmaps: aliases.cf
	bash _build_virtual.sh

postfix_virtual_aliasmaps_regexp: regexp.cf
	bash _build_virtual.sh

postfix_virtual_domains: accounts.cf aliases.cf
	bash _build_virtual.sh

postfix_virtual_mailboxmaps: accounts.cf
	bash _build_virtual.sh
	
mailboxes: accounts.cf	## Make sure mailboxes are created
	sudo bash _make_mailboxes.sh
	
/etc/postfix/virtual/domains: postfix_virtual_domains
	sudo cp $+ $@
	
/etc/postfix/virtual/mailbox_maps: postfix_virtual_mailboxmaps
	sudo cp $+ $@
	sudo postmap $@
	
/etc/postfix/virtual/alias_maps: postfix_virtual_aliasmaps
	sudo cp $+ $@
	sudo postmap $@

/etc/postfix/virtual/alias_maps_regexp: postfix_virtual_aliasmaps_regexp
	sudo cp $+ $@

/etc/dovecot/userdb: dovecot_userdb
	sudo cp $+ $@
	sudo chown dovecot:dovecot $@
	sudo chmod 640 $@

postfix-localconf: postfix_virtual_aliasmaps postfix_virtual_aliasmaps_regexp postfix_virtual_domains postfix_virtual_mailboxmaps

postfix-local-clean:
	rm -f postfix_virtual_aliasmaps postfix_virtual_aliasmaps_regexp postfix_virtual_domains postfix_virtual_mailboxmaps

dovecot-localconf: dovecot_userdb

dovecot-local-clean:
	rm -f dovecot_userdb

localconf: postfix-localconf dovecot-localconf	## Do local copies of all configurations

postfix-conf: /etc/postfix/virtual/domains /etc/postfix/virtual/mailbox_maps /etc/postfix/virtual/alias_maps /etc/postfix/virtual/alias_maps_regexp		## Do the postfix configuration

postfix-reload: postfix-conf
	sudo service postfix reload

dovecot-conf: /etc/dovecot/userdb	## Do the dovecot configuration

dovecot-reload: dovecot-conf
	sudo service dovecot reload