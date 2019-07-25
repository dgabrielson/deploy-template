
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    


lamp.evt: | fabadmin.evt	## Install LAMP stack
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		 deploy.lamp:'lang=libapache2-mod-php,phpmyadmin=True,extras=php-mysql'
	touch "$@"
	
