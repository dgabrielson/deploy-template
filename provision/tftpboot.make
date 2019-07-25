
PROVISION_IP_ADDR = $(shell ../_scripts/cluster-conf provision ip-address)


tftp_install.evt: 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
        deploy.tftpd
	touch "$@"


payload/tftpboot/pxelinux.cfg/default: payload/tftpboot/pxelinux.cfg/default.tmpl ../settings.mk
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g' -e 's/CLUSTERADMIN/$(CLUSTER_USER)/g' -e 's/PROVISION_IP_ADDR/$(PROVISION_IP_ADDR)/g'  $< > $@


tftpboot.evt: payload/tftpboot payload/tftpboot/pxelinux.cfg/default | tftp_install.evt fabadmin.evt	## Update tftpboot directory
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/var/lib,use_sudo=True"
	touch "$@"
