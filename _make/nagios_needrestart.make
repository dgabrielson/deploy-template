
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



nagios_needrestart.evt: SCRIPT_NAME = $(shell basename $<)
nagios_needrestart.evt: ../_nrpe/nagios_needrestart.sh sudoers_needrestart.evt | fabadmin.evt ## Ensure remote system can check if restart is required
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True" \
		sudo:"chown root:root /usr/local/sbin/$(SCRIPT_NAME)" \
		sudo:"chmod +x /usr/local/sbin/$(SCRIPT_NAME)"
	touch "$@"

	
sudoers_needrestart.evt: ../_nrpe/40_needrestart | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.include_sudoers:"$<"
	touch "$@"
