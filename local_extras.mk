
# This file defines the local extras targets; and rules to make them.

LOCAL_EXTRAS = kvm0/payload/ssh_config


logapp/payload/django.conf.json: cluster.conf _scripts/syslog_host_choices.py
	$(MAKE) -C logapp payload/django.conf.json


mcp/payload/conf.d/cluster-hosts.cfg: cluster.conf _scripts/nagios-hosts.awk
	$(MAKE) -C mcp payload/conf.d/cluster-hosts.cfg


mcp/payload/config.json: cluster.conf _scripts/mgmt-fab-conf.py
	$(MAKE) -C mcp payload/config.json


provision/payload/dhcpd.conf: cluster.conf _scripts/dhcpd.awk
	$(MAKE) -C provision payload/dhcpd.conf


kvm0/payload/ssh_config: ssh-config.pre ssh-config.gen	
	cat $+ > $@