
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)



virtualenv.prep.evt: | fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.pyenv.prep
	touch "$@"

virtualenv.evt: payload/requirements.txt | virtualenv.prep.evt django-user.evt ## create or update a python virtual environment
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u django -H $(FQDN) \
		deploy.pyenv.create:"$(NAME),$<,local=True" \
		run:"rm $(NAME).requirements.txt"
	touch "$@"
