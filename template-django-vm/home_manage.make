
home_manage.evt: payload/manage.sh | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"mkdir -p ~$(DEPLOY_ADMIN)/bin" \
		sudo:"chown -R $(DEPLOY_ADMIN) ~$(DEPLOY_ADMIN)/bin" \
		deploy.putconf:"$<,~$(DEPLOY_ADMIN)/bin/,use_sudo=True,mode=0755"
	touch "$@"
