
deploy_install.evt: deploy_core.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(CLUSTER_USER) -H $(FQDN) \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get install -y -qq libffi-dev libssl-dev" 
	touch "$@"


deploy_venv.evt: payload/requirements.txt deploy_install.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(CLUSTER_USER) -H $(FQDN) \
		deploy.pyenv.create:"fab,payload/requirements.txt,local=True" \
		run:"echo /home/$(CLUSTER_USER)/mgmt-fab > /home/$(CLUSTER_USER)/.virtualenvs/fab/.project"
	touch "$@"
