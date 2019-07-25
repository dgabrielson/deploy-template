#
# This target uses the storage.deps.evt dependency to ensure that the
#   storage location has been properly prepped.
# Recommended to specify this target in the deploy_$(NAME).make file.
#


include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN) 



storage_html_index.evt: payload/index.html storage.deps.evt | fabadmin.evt	## Update /storage/html/index.html
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,index.html,use_sudo=False,mode=0664" \
		run:"sg $(DEPLOY_ADMIN) -c 'cp index.html /storage/html/'" \
		run:"rm index.html"
	touch "$@"
	
# Note here the use of the "sg" command to do a single command with an
#	altered group context.  This is required to write the file to the 
#	DEPLOY_ADMIN owned storage area.
