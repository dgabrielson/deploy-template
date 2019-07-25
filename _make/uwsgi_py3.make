
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)




uwsgi-py3-install.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
	    deploy.uwsgi.install:"python3=True"
	touch "$@"


uwsgi.ini.evt: payload/uwsgi.ini | uwsgi-py3-install.evt fabadmin.evt ## Enable a uWSGI application
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.uwsgi.enable_local_app:"$(NAME).ini,$<"
	touch "$@"
