
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    


apt-sources.hwraid.evt: 
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'apt-get install -qq -y apt-transport-https' \
		sudo:"echo 'deb https://hwraid.le-vert.net/ubuntu xenial main' > /etc/apt/sources.list.d/hwraid.le-vert.net.sources.list" \
		sudo:'wget -O - https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | apt-key add -' \
		sudo:'apt-get update -qq'
	touch "$@"
	

