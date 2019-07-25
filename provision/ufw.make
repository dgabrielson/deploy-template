ufw.evt: 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"apt-get install -qq -y ufw" \
		deploy.nat_forward.ufw_enable:"$(MGMT_NET),ens2"
	touch "$@"
