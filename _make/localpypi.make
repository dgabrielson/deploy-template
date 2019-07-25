
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)
# Required additional variables:
$(call check_defined, PYPI)    



localpypi.evt: | django-user.evt	## Setup an alternate PiPy repository
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u django -H $(FQDN) \
		deploy.pyenv.localpypi:"$(PYPI)"
	touch "$@"

