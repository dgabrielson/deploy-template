
dhcpd.conf-gen: ../cluster.conf ../_scripts/dhcpd.awk
	../_scripts/dhcpd.awk ../cluster.conf > dhcpd.conf-gen


payload/dhcpd.conf: payload/dhcpd.conf-pre dhcpd.conf-gen
	cat $^ > $@


dhcpd_install.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.dhcp_server.install
	touch "$@"


dhcpd.evt: payload/dhcpd.conf | dhcpd_install.evt fabadmin.evt	## Update dhcpd configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.dhcp_server.local_config:"$<"
	touch "$@"
	
