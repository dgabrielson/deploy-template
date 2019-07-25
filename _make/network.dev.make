
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



network_interfaces.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.network_interfaces.reset
	touch "$@"

network.%.evt: DEVNAME = $(shell basename $<)
network.%.evt: payload/% | network_interfaces.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/network/interfaces.d/,use_sudo=True,mode=0644" \
		sudo:"if ifquery --state $(DEVNAME); then ifdown $(DEVNAME) && ifup $(DEVNAME); else ifup $(DEVNAME); fi"
	touch "$@"

# When using this makefile, create your own network.evt make goal
#	which calls the various network.DEVNAME.evt as dependencies.