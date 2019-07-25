
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN )


rstudioserver-systemd.evt: rstudio_install.evt | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if ! test -d /etc/systemd/system/rstudio-server.service.d; then mkdir /etc/systemd/system/rstudio-server.service.d; fi' \
		sudo:'echo -e "[Unit]\nAfter\=network-online" | tee /etc/systemd/system/rstudio-server.service.d/local.conf' \
		sudo:'systemctl daemon-reload'
	touch "$@"


rstudio_install.evt: | usr_local_sbin.rstudio_updater.evt r_install.evt fabadmin.evt   ## Install RStudio server
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'/usr/local/sbin/rstudio_updater --nodelay'
	touch "$@"
