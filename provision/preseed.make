include ../settings.mk

payload/preseed.cfg: payload/preseed.cfg.tmpl payload/preseed.user.tmpl ../settings.mk
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g'  -e 's/CLUSTER_ADMIN/$(CLUSTER_USER)/g' payload/preseed.cfg.tmpl > $@
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g'  -e 's/CLUSTER_ADMIN/$(CLUSTER_USER)/g' payload/preseed.user.tmpl >> $@


preseed.evt: payload/preseed.cfg | fabadmin.evt	## Update /var/www/html/preseed.cfg
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/var/www/html,use_sudo=True,mode=0644"
	touch "$@"
	
