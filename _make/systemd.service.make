
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)    



systemd_reload.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'systemctl daemon-reload'
	touch "$@"

systemd_service.%.evt: SVCNAME = $(shell basename $<)
systemd_service.%.evt: payload/%.service | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/systemd/system/,use_sudo=True,mode=0644" \
		sudo:'systemctl daemon-reload' \
		sudo:"if ! systemctl list-unit-files | grep $(SVCNAME).*enabled; then systemctl enable $(SVCNAME); fi" \
		sudo:"if systemctl | grep $(SVCNAME).*running; then systemctl restart $(SVCNAME); else systemctl start $(SVCNAME); fi"
	touch "$@"

# When using this makefile, create your own systemd_service.evt make goal
#	which calls the various systemd_service.SVCNAME.evt as dependencies.
# E.g.:: systemd_service.evt: systemd_service.gradebook-calculate.evt