
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



var_www_html_index.evt: payload/index.html | fabadmin.evt	## Update /var/www/html/index.html
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
	    sudo:"mkdir -p /var/www/html" \
		deploy.putconf:"$<,/var/www/html,use_sudo=True,mode=0644"
	touch "$@"
	
