include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



nfs_home.evt: payload/nfs_mkhomedir | fabadmin.evt       ## Update /var/www/html/index.html
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/share/pam-configs/,use_sudo=True,mode=0640" \
		sudo:"pam-auth-update"
	touch "$@"

