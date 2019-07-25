
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)



samba_install.evt: | fabadmin.evt   ## Install samba
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		 deploy.samba
	touch "$@"



samba.evt: payload/smb.conf | samba_install.evt fabadmin.evt	## Update samba configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/samba/smb.conf" \
	    sudo:'sudo systemctl restart smbd' \
	    sudo:'sudo systemctl restart nmbd'
	touch "$@"
