


etc-skel.evt: payload/etc-skel \
	payload/etc-skel/.bash_profile \
	payload/etc-skel/.ssh/known_hosts \
	| fabadmin.evt	## Update system /etc/skel
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,." \
		sudo:'chown -R root:root etc-skel' \
		sudo:'cp -r etc-skel/. /etc/skel' \
		sudo:'rm -rf etc-skel'
	touch "$@"
