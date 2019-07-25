

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)
# Required additional variables:
$(call check_defined, NFSFQDN NFSHOSTPATH NFSCLIENT)


# Note: generally recommend to use auto.local.make and files_client.make
#	instead.



nfs_storage.evt:
	ping -qc 1 $(NFSFQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -H $(DEPLOY_ADMIN)@$(NFSFQDN) \
		sudo:"mkdir -p $(NFSHOSTPATH)/{backup\,bin\,html\,ssl\,var}" \
		sudo:"mkdir -p $(NFSHOSTPATH)/html/{static\,media}" \
		sudo:"chown -R $(DEPLOY_ADMIN):$(DEPLOY_ADMIN) $(NFSHOSTPATH)" \
		sudo:"chown -R $(DEPLOY_ADMIN):www-data $(NFSHOSTPATH)/html" \
		sudo:"chmod -R a+rX $(NFSHOSTPATH)/html" \
		sudo:"chmod -R g+w $(NFSHOSTPATH)/html/media"
	touch "$@"


nfs_client.evt: | nfs_storage.evt fabadmin.evt	## Setup an nfs client
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.nfs_client:"$(NFSCLIENT)" \
		sudo:"if ! systemctl list-unit-files | grep rpc-statd.*enabled; then systemctl enable rpc-statd; fi" \
        sudo:"if systemctl | grep rpc-statd.*running; then systemctl restart rpc-statd; else systemctl start rpc-statd; fi"
	touch "$@"
