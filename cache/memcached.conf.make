memcached.conf.evt: payload/memcached.conf | fabadmin.evt	## Update  memcached configuration
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.memcached.local_config:"$<"
	touch "$@"