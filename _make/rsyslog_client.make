
ifeq ($(LOGHOST),)
    LOGHOST = $(shell ../_scripts/cluster-conf logsrv ip-address)
endif

ifeq ($(LOGHOST),)
    $(error LOGHOST not set, and no ip address for logsrv found)
endif 

include ../_make/lib/check_defined.mk
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN \
                      LOGHOST)


rsyslog_client.evt: | fabadmin.evt	## Setup central logging
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.rsyslog.client:"$(LOGHOST)"
	touch "$@"

