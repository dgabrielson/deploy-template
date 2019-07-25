
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME DEPLOY_ADMIN)
# Required additional variables:
$(call check_defined, PYPI)


# This is a python3 virtualenv.
jupyterhub_venv_prep.evt:
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.pyenv.localpypi:"$(PYPI)" \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get -qq -y install python3-venv python3-dev" \
		sudo:"apt-get -qq -y install npm nodejs node-gyp nodejs-dev libssl1.0-dev" \
		sudo:"npm install -g configurable-http-proxy"
	touch "$@"


jupyterhub_venv.evt: VENV_PATH = /usr/local/share/jupyterhub/
jupyterhub_venv.evt: SVCNAME = jupyterhub
jupyterhub_venv.evt: payload/jupyterhub.reqs.txt | jupyterhub_venv_prep.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
        deploy.pyenv.create_py3:"$(VENV_PATH),$<,local=True,use_sudo=True"
	touch "$@"


jupyterhub-kernels.evt: VENV_PATH = /usr/local/share/jupyterhub/
jupyterhub-kernels.evt: SVCNAME = jupyterhub
jupyterhub-kernels.evt: jupyterhub_venv.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"if test -d /usr/share/jupyter/kernels/sagemath; then cp -r --copy-contents /usr/share/jupyter/kernels/sagemath $(VENV_PATH)share/jupyter/kernels/; fi" \
		sudo:"if test -f $(VENV_PATH)share/jupyter/kernels/sagemath/kernel.json; then sed -i~ -e 's#--python#--python2#g' $(VENV_PATH)share/jupyter/kernels/sagemath/kernel.json; fi" \
		sudo:"if systemctl | grep $(SVCNAME); then if systemctl | grep $(SVCNAME).*running; then systemctl restart $(SVCNAME); else systemctl start $(SVCNAME); fi; fi"
	touch "$@"


jupyterhub-settings.evt: SVCNAME = jupyterhub
jupyterhub-settings.evt: payload/jupyterhub_config.py  | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"if ! test -d /etc/jupyterhub; then mkdir -p /etc/jupyterhub; fi" \
		deploy.putconf:"$<,/etc/jupyterhub/,use_sudo=True,mode=0644" \
		sudo:"if systemctl | grep $(SVCNAME); then if systemctl | grep $(SVCNAME).*running; then systemctl restart $(SVCNAME); else systemctl start $(SVCNAME); fi; fi"
	touch "$@"
