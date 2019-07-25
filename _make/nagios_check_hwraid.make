
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



sudoers_hwraid.evt: ../_nrpe/30_check-raid | fabadmin.evt	## Ensure that remote system can do hwraid checks
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.include_sudoers:"$<"
	touch "$@"


# You will need one of hwraid_{debian,ubuntu}.make in order for this to work.

check_hwraid_inst.evt: | apt-sources.hwraid.evt fabadmin.evt   ## Install the megaclisas-status command line tools
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'apt-get install -qq -y megaclisas-status'
	touch "$@"
