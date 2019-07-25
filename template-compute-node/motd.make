
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN )


motd_urls.evt: URLS = https://gauss.math.umanitoba.ca/motd/
motd_urls.evt: | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'sed -i~ -e s#^URLS\=.*#URLS\=\\"$(URLS)\\"# /etc/default/motd-news'
	touch "$@"
