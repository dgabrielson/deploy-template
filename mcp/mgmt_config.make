
include ../settings.mk

PHYS_NAMES = $(shell cut -f 1 ../phys-hosts.conf | grep -v ^\#)
VIRT_NAMES = $(shell cut -f 1 ../virt-hosts.conf | grep -v ^\#)

payload/config.json: ../cluster.conf ../_scripts/mgmt-fab-conf.py
	../_scripts/mgmt-fab-conf.py -u fabadmin -d $(CLUSTER_DOMAIN) --role "phys:$(PHYS_NAMES)" --role "virt:$(VIRT_NAMES)" $< -o $@
#../_scripts/mgmt-fab-conf.py --host 'gabriels:LopiWeje3;Mino@kvm0.math.umanitoba.ca' -d $(CLUSTER_DOMAIN) --role "phys:$(PHYS_NAMES)" --role "virt:$(VIRT_NAMES)" $< -o $@


config.json.evt: payload/config.json | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/mgmt-config.json,use_sudo=True,mode=0644"
	touch "$@"
