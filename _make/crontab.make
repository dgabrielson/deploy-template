
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)    



crontab.evt: payload/crontab.txt | fabadmin.evt	## Update remote crontab
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.crontab:"$<,user=$(DEPLOY_ADMIN)"
	touch "$@"