
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)

include ../_make/nrpe_std_checks.make


monitoring_plugins.evt: | fabadmin.evt	## Install monitoring plugins
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'apt install -yq monitoring-plugins'
	touch "$@"


nrpe_install.evt: | fabadmin.evt	## Install nagios nrpe server
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.nagios.nrpe
	touch "$@"


local_nrpe.evt: payload/local_nrpe.cfg nrpe_std_checks.evt | monitoring_plugins.evt nrpe_install.evt fabadmin.evt	## Update remote nrpe configuration
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.nagios.nrpe:"$<,update_conf=1"
	touch "$@"
