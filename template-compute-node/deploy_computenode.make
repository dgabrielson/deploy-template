auto.local.deps.evt:
	touch "$@"

# Setup additional local binaries/scripts
include ../_make/usr_local_bin.make
local_bin.evt: usr_local_bin.cluster.evt usr_local_bin.localtask.evt \
	usr_local_bin.enable_jupyterhub_julia_notebook.evt \
	usr_local_bin.enable_jupyterhub_r_notebook.evt

include ../_make/usr_local_sbin.make
local_sbin.evt: usr_local_sbin.rstudio_updater.evt \
	usr_local_sbin.julialang_updater.evt usr_local_sbin.julialang_latest_url.evt \
	usr_local_sbin.nagios_check_tasks.evt \
	usr_local_sbin.r_system_packages_update.evt \
	usr_local_sbin.shinyserver_updater.evt usr_local_sbin.shinyserver_latest_url.evt \
	usr_local_sbin.check_ldapc.evt


include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)


julialang_install.evt: usr_local_sbin.julialang_updater.evt usr_local_sbin.julialang_latest_url.evt | fabadmin.evt
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'/usr/local/sbin/julialang_updater --nodelay'
	touch "$@"
