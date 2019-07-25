#
# This target uses the storage.deps.evt dependency to ensure that the
#   storage location has been properly prepped.
# Recommended to specify this target in the deploy_$(NAME).make file.
#


include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)



storage_backup.evt: payload/backup.sh storage.deps.evt | fabadmin.evt	## Ensure remote backup script is updated and executable
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,.,use_sudo=False,mode=0755" \
		sudo:"chown $(DEPLOY_ADMIN) backup.sh" \
		sudo:"su $(DEPLOY_ADMIN) -c 'cp backup.sh /storage/bin/backup.sh'" \
		run:'rm backup.sh'
	touch "$@"
	
# Note here the use of the "su" command to do a single command with an
#	altered group context.  This is required to write the file to the 
#	DEPLOY_ADMIN owned storage area.
