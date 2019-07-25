
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)



nginx_install.evt: | fabadmin.evt   ## Install nginx
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		 deploy.nginx.install
	touch "$@"



nginx.evt: payload/nginx.conf | nginx_install.evt fabadmin.evt	## Update nginx configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if test -f /etc/nginx/sites-enabled/default; then rm /etc/nginx/sites-enabled/default; fi' \
		deploy.nginx.enable_local_site:"50_$(NAME).conf,$<"
	touch "$@"
	
