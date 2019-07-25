
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



dnsmasq_restart.evt: hosts.extra.evt    ## Automatically restart dnsmasq when hosts.extra changes.
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"systemctl restart dnsmasq.service"
	touch "$@"
	

dnsmasq_install.evt:  | fabadmin.evt    ## Install dnsmasq
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved || true' \
		deploy.dnsmasq.install
	touch "$@"


dnsmasq.evt: payload/dnsmasq.conf | dnsmasq_install.evt fabadmin.evt	## Update dnsmasq configuration.
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.dnsmasq.local_config:"$<"
	touch "$@"
	
