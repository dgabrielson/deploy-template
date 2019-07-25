
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)    



django-settings.evt: payload/django-settings.json uwsgi.ini.evt | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/$(NAME)-settings.json,use_sudo=True,mode=0644" \
		sudo:"touch /etc/uwsgi/$(NAME).ini"
	touch "$@"
