network2.%.evt: DEVNAME = $(shell grep ^iface $< | cut -f 2 -d ' ' | tail -n 1)
network2.%.evt: payload/% | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
	        deploy.putconf:"$<,/etc/network/interfaces.d/,use_sudo=True,mode=0644" \
	        sudo:"if ifquery --state $(DEVNAME); then ifdown $(DEVNAME) && ifup $(DEVNAME); else ifup $(DEVNAME); fi"
	touch "$@"
