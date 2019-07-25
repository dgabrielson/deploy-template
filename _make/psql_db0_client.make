#
# Add a postgresql user and database on the db0 server.
#
# Standard inputs::
# 	VIRTUAL_ENV, MGMT_FABFILE, DOMAIN, IP_ADDRESS
#
# Additional inputs::
#	DBNAME - the name of the newly created database
#	DBUSER - the owner of the new database
#	DBPASSWD - the owner's password
#

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE DOMAIN IP_ADDRESS)
# Required additional variables:
$(call check_defined, DBNAME DBUSER DBPASSWD)



psql_db0_client.evt: ../db0/deploy_extras.evt
	ping -qc 1 db0.$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H db0.$(DOMAIN) \
		deploy.postgresql.createuser:"$(DBUSER),$(DBPASSWD)" \
		deploy.postgresql.createdb:"$(DBNAME),$(DBUSER)" \
		deploy.postgresql.grant_host_access:"$(DBNAME),$(DBUSER),$(IP_ADDRESS)/32" 
	touch "$@"



 