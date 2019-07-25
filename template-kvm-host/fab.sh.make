
fab.sh.evt: payload/fab.sh | bashrc.post.evt 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		run:"mkdir -p ~/.bash_functions.d/" \
		deploy.putconf:"$<,.bash_functions.d/,use_sudo=False,mode=0644"
	touch "$@"
