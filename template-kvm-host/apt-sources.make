

# HW RAID
apt-sources.hwraid.evt: payload/sources.list.d/hwraid.le-vert.net.sources.list
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/apt/sources.list.d/,use_sudo=True,mode=0644" \
		sudo:'wget -O - https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | apt-key add -' 
	touch "$@"


# https://linux.dell.com/repo/community/ubuntu/	
apt-sources.linux.dell.evt: payload/sources.list.d/linux.dell.sources.list
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/apt/sources.list.d/,use_sudo=True,mode=0644" \
		sudo:'apt-key adv --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F' 
	touch "$@"


apt-sources.evt: apt-sources.hwraid.evt apt-sources.linux.dell.evt | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'apt-get -y update' 
	touch "$@"

