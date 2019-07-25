# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)


mgmt-fabric-host.sbin.evt: SBIN_NAME=$(shell basename $@ .sbin.evt)
mgmt-fabric-host.sbin.evt: payload/mgmt-fabric-host | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/local/sbin/,use_sudo=True,mode=0755" 
	touch "$@"
