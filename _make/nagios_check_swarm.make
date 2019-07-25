
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



nagios_check_swarm.evt: SCRIPT_NAME = $(shell basename $<)
nagios_check_swarm.evt: ../_nrpe/check_swarm.sh | fabadmin.evt	## Ensure remote system can do NRPE checks for docker services
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True" \
		sudo:"chown root:root /usr/local/sbin/$(SCRIPT_NAME)" \
		sudo:"chmod +x /usr/local/sbin/$(SCRIPT_NAME)"
	touch "$@"


sudoers_check_swarm.evt: ../_nrpe/52_check_swarm | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
			deploy.include_sudoers:"$<"
	touch "$@"
