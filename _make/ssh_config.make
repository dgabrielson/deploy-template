
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE DEPLOY_ADMIN FQDN)



ssh_config.evt: payload/ssh_config ## Update remote ssh config 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
	    run:"mkdir -p ~/.ssh/" \
		deploy.putconf:"$<,./.ssh/config"
	touch "$@"
