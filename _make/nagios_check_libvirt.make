
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



sudoers_libvirt.evt: ../_nrpe/50_check_libvirt | fabadmin.evt	## Ensure that remote system can do hwraid checks
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.include_sudoers:"$<"
	touch "$@"


check_libvirt_inst.evt: | fabadmin.evt   ## Install the megaclisas-status command line tools
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'apt install -q -y nagios-plugins-contrib libsys-virt-perl'
	touch "$@"
