#
# This target uses the auto.local.deps.evt dependency to ensure that the
#   any server side dependencies have been properly prepped.
# Recommended to specify this target in the deploy_$(NAME).make file.
#

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)


auto.local.evt: payload/auto.local auto.local.deps.evt | fabadmin.evt	## Update auto.local and reload autofs
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
	    deploy.autofs.init \
		sudo:"if ! systemctl list-unit-files | grep rpc-statd.*enabled; then systemctl enable rpc-statd; fi" \
		sudo:"if systemctl | grep rpc-statd.*running; then systemctl restart rpc-statd; else systemctl start rpc-statd; fi" \
		deploy.putconf:"$<,/etc,use_sudo=True,mode=0644" \
		deploy.autofs.reload \
		sudo:'systemctl restart autofs'
	touch "$@"
