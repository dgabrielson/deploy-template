
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



nagios_check_uwsgi.evt: SCRIPT_NAME = $(shell basename $<)
nagios_check_uwsgi.evt: ../_nrpe/check_uwsgi.py | fabadmin.evt	## Ensure remote system can do NRPE checks for memory
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True" \
		sudo:"chown root:root /usr/local/sbin/$(SCRIPT_NAME)" \
		sudo:"chmod +x /usr/local/sbin/$(SCRIPT_NAME)"
	touch "$@"
