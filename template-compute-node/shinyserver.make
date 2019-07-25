
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN )


shinyserver-conf.evt: SVCNAME = shiny-server
shinyserver-conf.evt: payload/shiny-server.conf | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if ! test -d /etc/shiny-server; then mkdir /etc/shiny-server; fi' \
		deploy.putconf:"$<,/etc/shiny-server/,use_sudo=True,mode=0755" \
		sudo:"if systemctl | grep $(SVCNAME).*running; then systemctl restart $(SVCNAME); else if systemctl | grep $(SVCNAME); then systemctl start $(SVCNAME); fi; fi"
	touch "$@"

shinyserver-systemd.evt: shinyserver_install.evt | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if ! test -d /etc/systemd/system/shiny-server.service.d; then mkdir /etc/systemd/system/shiny-server.service.d; fi' \
		sudo:'echo -e "[Unit]\nAfter\=network-online" | tee /etc/systemd/system/shiny-server.service.d/local.conf' \
		sudo:'systemctl daemon-reload'
	touch "$@"


shinyserver_install.evt: | usr_local_sbin.shinyserver_updater.evt r_install.evt fabadmin.evt   ## Install shiny server
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'/usr/local/sbin/shinyserver_updater --nodelay'
	touch "$@"
