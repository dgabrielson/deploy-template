nagios_check_tasks.evt: SCRIPT_NAME = $(shell basename $<)
nagios_check_tasks.evt: payload/nagios_check_tasks.sh | fabadmin.evt	## Ensure remote system can do NRPE checks for systemd services
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True" \
		sudo:"chown root:root /usr/local/sbin/$(SCRIPT_NAME)" \
		sudo:"chmod +x /usr/local/sbin/$(SCRIPT_NAME)"
	touch "$@"
