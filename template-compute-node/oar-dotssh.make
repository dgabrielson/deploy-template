


oar-dotssh.evt: payload/oar-dotssh \
	payload/oar-dotssh/authorized_keys \
	payload/oar-dotssh/config \
	payload/oar-dotssh/id_rsa \
	payload/oar-dotssh/id_rsa.pub \
	| fabadmin.evt apt_packages.evt	## Update OAR ssh directory
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,." \
		sudo:'chown -R oar:oar oar-dotssh' \
		sudo:'rm -rf /var/lib/oar/.ssh' \
		sudo:'mv oar-dotssh /var/lib/oar/.ssh' \
		sudo:'chmod 0600 /var/lib/oar/.ssh/id_rsa'
	touch "$@"
