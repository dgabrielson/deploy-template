
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)


docker_engine.evt:
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.docker.install_engine
	touch "$@"


# TODO: figure out how to deliver context to target machine.
docker.%.script.evt: NAME = $(shell basename $$(basename "$<") .dockerscript)
docker.%.script.evt: payload/%.dockerscript | docker_engine.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,./" \
		sudo:'bash "$(NAME).dockerscript"' \
		run:'rm "$(NAME).dockerscript"'
	touch "$@"
