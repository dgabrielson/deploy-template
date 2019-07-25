
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)    


# NOTE: fabadmin is not used because of extra user context.

django-user.evt: | fabadmin.evt ## Add a django user.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		deploy.adduser:"django,groups=www-data" \
		authorize_ssh:"user=django"
	touch "$@"
