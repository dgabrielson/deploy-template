


auto.local.deps.evt: deploy_files_client.evt	## ensure auto.local.evt dependencies have been met.
	touch "$@"
	
storage.deps.evt: auto.local.evt	## ensure /storage is ready to go.
	touch "$@"


# NOTE: fabadmin for security reasons cannot be a user other than root;
#	however the deploy.postgresql.* commands occasionally rely on 
#	running as the user 'postgres'; thus we run as $(DEPLOY_ADMIN)
#	(instead of fabadmin).


include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN DEPLOY_ADMIN)    
# Required extra variables:
$(call check_defined, DBUSER DBPASS MONITOR_IP)


deploy_extras.evt: deploy_files_client.evt | vdb_data.evt deploy.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(FQDN) \
		deploy.postgresql.install \
		deploy.postgresql.createuser:"$(DBUSER),$(DBPASS)" \
		deploy.postgresql.grant_host_access:"$(DBNAME),$(DBUSER),$(MONITOR_IP)/32,trust"
	touch "$@"


