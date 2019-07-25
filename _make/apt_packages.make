
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



apt_packages.evt: PKGS = $(shell cat $<)
apt_packages.evt: payload/apt_packages.txt | fabadmin.evt	## Install packages listed in payload/apt_packages.txt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"apt-get install -qq -y $(PKGS)"
	touch "$@"
	
