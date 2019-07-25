dhclient.conf.evt: payload/dhclient.conf | fabadmin.evt	## Update dhclient configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/dhcp/" \
		sudo:"dhclient -r" \
		sudo:"dhclient"
	touch "$@"
