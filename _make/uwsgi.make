
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)




uwsgi-install.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
	    deploy.uwsgi.install
	touch "$@"


uwsgi.ini.evt: payload/uwsgi.ini | uwsgi-install.evt fabadmin.evt ## Enable a uWSGI application
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.uwsgi.enable_local_app:"$(NAME).ini,$<"
	touch "$@"
