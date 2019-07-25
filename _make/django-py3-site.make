
# PYTHON3 Django site.

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME DEPLOY_ADMIN)
# Required additional variables:
$(call check_defined, PYPI VENV_PATH)



# This is a python3 virtualenv.
django_venv_prep.evt:
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.pyenv.localpypi:"$(PYPI)" \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get -qq -y install python3-venv python3-dev"
	touch "$@"


django_venv.evt: payload/django.reqs.txt | django_venv_prep.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
        deploy.pyenv.create_py3:"$(VENV_PATH),$<,local=True,use_sudo=True"
	touch "$@"


django-admin.sbin.evt: SBIN_NAME=$(shell basename $@ .sbin.evt)
django-admin.sbin.evt: | django_venv.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"echo '#!/bin/bash' > /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo 'source "$(VENV_PATH)bin/activate"' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"echo '$(VENV_PATH)bin/manage.py \"\$$@\"' >> /usr/local/sbin/$(SBIN_NAME)" \
		sudo:"chmod 755 /usr/local/sbin/$(SBIN_NAME)"
	touch "$@"


django-settings.evt: VENV_NAME=$(shell basename $(VENV_PATH))
django-settings.evt: payload/django-settings.json  | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/$(VENV_NAME)-settings.json,use_sudo=True,mode=0644" \
		sudo:'if test -f /etc/uwsgi/$(NAME).ini; then touch /etc/uwsgi/$(NAME).ini && echo "* uWSGI reloaded"; fi'
	touch "$@"


django-collectstatic.evt: django_venv.evt django-settings.evt | django-admin.sbin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		run:"/usr/local/sbin/django-admin collectstatic --noinput -v0"
	touch "$@"


django-migrate.evt: django_venv.evt django-settings.evt | django-admin.sbin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		run:"/usr/local/sbin/django-admin migrate -v0 --run-syncdb"
	touch "$@"


django-uwsgi-reload.evt: django_venv.evt django-migrate.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if test -f /etc/uwsgi/$(NAME).ini; then touch /etc/uwsgi/$(NAME).ini && echo "* uWSGI reloaded"; fi'
	touch "$@"
