
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)    



bashrc.post.evt: payload/bashrc.post | deploy.evt 	# Add to $(DEPLOY_ADMIN)'s .bashrc file.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		deploy.extend_bashrc:"$<" 
	touch "$@"
