
NAGIOS_ADM_PASS = \pi\simeq3.14159

ETC_NAGIOS3_WEB = apache2.conf.evt cgi.cfg.evt htpasswd.users.evt
CONF_D = $(shell find payload/conf.d -type f -print)

$(ETC_NAGIOS3_WEB): %.evt: payload/%
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/nagios3,use_sudo=True"
	touch "$@"


nagios_install.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.nagios.server \
		sudo:"htpasswd -bc /etc/nagios3/htpasswd.users nagiosadmin $(NAGIOS_ADM_PASS)"
	touch "$@"


conf.d.evt: payload/conf.d $(CONF_D) | nagios_install.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"rm /etc/nagios3/conf.d/*" \
		deploy.putconf:"$<,/etc/nagios3,use_sudo=True"
	touch "$@"


payload/conf.d/cluster-hosts.cfg: ../cluster.conf ../_scripts/nagios-hosts.awk
	../_scripts/nagios-hosts.awk $< > $@


config.inc.php.evt: payload/config.inc.php | nagios_install.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/usr/share/nagios3/htdocs,use_sudo=True"
	touch "$@"


nagios_server_cfg.evt: conf.d.evt | nagios_install.evt	## Update nagios server configuration
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"/usr/sbin/nagios3 -v /etc/nagios3/nagios.cfg" \
		sudo:"systemctl reload nagios3"
	touch "$@"


nagios_server_web.evt: $(ETC_NAGIOS3_WEB) config.inc.php.evt | nagios_install.evt	## Update nagios web server configuration
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"systemctl reload apache2.service"
	touch "$@"
	
