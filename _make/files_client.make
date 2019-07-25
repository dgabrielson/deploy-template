#
# Add the standard files server side share points.
# Usually used in conjunction with auto.local.make
#
# Standard inputs::
#   VIRTUAL_ENV, MGMT_FABFILE, DEPLOY_ADMIN, NAME, and DOMAIN
# 


include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE DEPLOY_ADMIN NAME DOMAIN)    


deploy_files_client.evt: ../files/deploy_extras.evt	## Create the standard files/host server side directories.
	ping -qc 1 files.$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H files.$(DOMAIN) \
			sudo:"mkdir -p /storage/host/$(NAME)/bin" \
			sudo:"mkdir -p /storage/host/$(NAME)/backup" \
			sudo:"mkdir -p /storage/host/$(NAME)/html" \
			sudo:"chown $(DEPLOY_ADMIN):$(DEPLOY_ADMIN) /storage/host/$(NAME)/bin" \
			sudo:"chown $(DEPLOY_ADMIN):$(DEPLOY_ADMIN) /storage/host/$(NAME)/backup" \
			sudo:"chown $(DEPLOY_ADMIN):www-data /storage/host/$(NAME)/html" \
			sudo:"chmod g+w /storage/host/$(NAME)/html"
	touch "$@"

