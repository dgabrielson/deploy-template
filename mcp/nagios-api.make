
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)


nagios_api_venv.evt: payload/nagios-api.reqs.txt | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get install -y -qq libffi-dev libssl-dev" \
		deploy.pyenv.create:"nagios-api,$<,local=True"
	touch "$@"


nagios-%.sbin.evt: SBIN_NAME=$(shell basename $@ .sbin.evt)
nagios-%.sbin.evt: VENV_PATH=/home/fabadmin/.virtualenvs/nagios-api/bin/
nagios-%.sbin.evt: | nagios_api_venv.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"echo '#!/bin/bash' > /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo 'source $(VENV_PATH)activate' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo '$(VENV_PATH)$(SBIN_NAME) \"\$$@\"' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"chmod 755 /usr/local/sbin/$(SBIN_NAME)"
	touch "$@"


nagios_api_symlinks.evt: nagios-api.sbin.evt nagios-cli.sbin.evt 


nagios_api_systemd.evt: payload/nagios-api.service | nagios_api_symlinks.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/lib/systemd/system/,use_sudo=True" \
		sudo:"systemctl enable nagios-api.service" \
		sudo:"systemctl start nagios-api.service"
	touch "$@"

