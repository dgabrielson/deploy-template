#
# Add multiple postgresql users and database(s) on the db0 server.
#
# Standard inputs::
# 	VIRTUAL_ENV, MGMT_FABFILE, DOMAIN, IP_ADDRESS
#

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE DOMAIN IP_ADDRESS)



psql_db0_client.evt: payload/db_client_access.txt ../db0/deploy_extras.evt
	ping -qc 1 db0.$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	bash ../_scripts/psql_db0_client_from_file_helper.sh $(MGMT_FABFILE) $(DEPLOY_ADMIN) $(DOMAIN) $(IP_ADDRESS) $<
	touch "$@"
