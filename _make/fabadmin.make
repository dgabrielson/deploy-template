
# although not ideal in terms of seperation of dependencies, this is 
#	done so in order to minimize the number of deploy admin password
#	prompts.

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)    


fabadmin.evt: ../_sudoers/fabadmin | deploy.evt	# Create remote fabadmin user
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		deploy.adduser:"fabadmin,groups=$(DEPLOY_ADMIN)" \
		authorize_ssh:"user=fabadmin" \
		deploy.include_sudoers:"$<"
	touch "$@"
