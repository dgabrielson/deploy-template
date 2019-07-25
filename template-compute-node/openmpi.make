
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN )


openmpi-conf.evt: payload/openmpi-mca-params.conf | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/openmpi/,use_sudo=True,mode=0755"
	touch "$@"

openmpi-hosts.evt: | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"ln -snf /storage/etc/cluster_hosts /etc/openmpi/openmpi-default-hostfile"
	touch "$@"
