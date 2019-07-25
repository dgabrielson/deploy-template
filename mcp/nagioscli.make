
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)
# Required additional variables:
$(call check_defined, PYPI)    


VENV_PATH="/usr/local/share/nagioscli/"


# This is a python3 virtualenv.
nagioscli_venv_prep.evt: 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.pyenv.localpypi:"$(PYPI)" \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get -qq -y install python3-venv"
	touch "$@"


nagioscli_venv.evt: payload/nagioscli.reqs.txt | nagioscli_venv_prep.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"python3 -m venv $(VENV_PATH)" \
		deploy.putconf:"$<,." \
		sudo:"source $(VENV_PATH)bin/activate && pip install -U -r nagioscli.reqs.txt" \
		run:"rm nagioscli.reqs.txt"
	touch "$@"
        

nagioscli.sbin.evt: SBIN_NAME=$(shell basename $@ .sbin.evt)
nagioscli.sbin.evt: | nagioscli_venv.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"echo '#!/bin/bash' > /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo 'source $(VENV_PATH)bin/activate' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo '$(VENV_PATH)bin/$(SBIN_NAME) \"\$$@\"' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"chmod 755 /usr/local/sbin/$(SBIN_NAME)"
	touch "$@"


nagioscli.conf.evt: payload/nagioscli.conf | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/.nagios-api-config,use_sudo=True,mode=644"
	touch "$@"

