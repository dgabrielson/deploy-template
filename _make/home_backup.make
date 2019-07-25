

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



home_backup.evt: payload/backup.sh | fabadmin.evt	## Ensure remote backup script is updated and executable
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		run:"mkdir -p ~/bin" \
		deploy.putconf:"$<,~/bin/,use_sudo=False,mode=0755"
	touch "$@"
	
