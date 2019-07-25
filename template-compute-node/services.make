
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN )


gauss_script.%.evt: payload/%.sh | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'mkdir -p /usr/local/gauss' \
		deploy.putconf:"$<,/usr/local/gauss/,use_sudo=True,mode=0755"
	touch "$@"


services.evt: gauss_script.computenode_poll.evt systemd_service.computenode_poll.evt \
	gauss_script.computenode_taskd.evt systemd_service.computenode_taskd.evt \
	gauss_script.jupyterhub.evt systemd_service.jupyterhub.evt


# NOTE: service names cannot have any periods in them:
systemd_restart.%.evt: SVCNAME = $(shell echo $@ | cut -f 2 -d .)
systemd_restart.%.evt: django_venv.evt | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"if systemctl | grep $(SVCNAME).*running; then systemctl restart $(SVCNAME); else systemctl start $(SVCNAME); fi"
	touch "$@"

systemd_restart.computenode_poll.evt: django-settings.evt

django_services.evt: systemd_restart.computenode_poll.evt systemd_restart.computenode_taskd.evt | services.evt
	touch "$@"

systemd_restart.jupyterhub.evt: services.evt jupyterhub_venv.evt jupyterhub-settings.evt
	touch "$@"

