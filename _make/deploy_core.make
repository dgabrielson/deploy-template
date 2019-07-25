
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN \
					  MAIL_RELAY DOMAIN ROOT_EMAIL)    



deploy_core.evt: | deploy.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		authorize_ssh \
		deploy.set_hostname:"$(FQDN)" \
		deploy.postfix.satellite:"relay=$(MAIL_RELAY),mailname=$(DOMAIN)" \
		deploy.linux:"root_alias=$(ROOT_EMAIL)" \
		sudo:"mkdir -p /var/www/empty"
	touch "$@"
