
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)



haproxy_install.evt: | fabadmin.evt   ## Install haproxy
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		 sudo:'apt install -qqy haproxy'
	touch "$@"



haproxy.evt: payload/haproxy.cfg | haproxy_install.evt fabadmin.evt	## Update haproxy configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/haproxy/,use_sudo=True" \
		sudo:'haproxy -c -f /etc/haproxy/' \
		sudo:'systemctl reload haproxy || systemctl start haproxy'
	touch "$@"
