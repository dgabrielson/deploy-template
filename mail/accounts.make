
ACCOUNTS := $(shell find payload/accounts -type f -print)

accounts.evt: payload/accounts $(ACCOUNTS)
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,." \
		sudo:'make -C ~/accounts all'
	touch "$@"
