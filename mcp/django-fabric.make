
django-fabric.evt: payload/django-fabric.json | fabadmin.evt 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/,use_sudo=True,mode=0644"
	touch "$@"
