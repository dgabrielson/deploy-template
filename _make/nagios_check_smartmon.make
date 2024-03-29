
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    


install_smartmontools.evt:
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"apt-get install -qq -y smartmontools"
	touch "$@"
	

nagios_check_smartmon.evt: SCRIPT_NAME = $(shell basename $<)
nagios_check_smartmon.evt: ../_nrpe/nagios_check_smartmon.py sudoers_check_smartmon.evt | fabadmin.evt install_smartmontools.evt 	## Ensure remote system can check SMART status
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True" \
		sudo:"chown root:root /usr/local/sbin/$(SCRIPT_NAME)" \
		sudo:"chmod +x /usr/local/sbin/$(SCRIPT_NAME)"
	touch "$@"

	
sudoers_check_smartmon.evt: ../_nrpe/30_check-smartmon | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.include_sudoers:"$<"
	touch "$@"
