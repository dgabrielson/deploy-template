
.DEFAULT_GOAL := update-configs
.PHONY = clean help
HELP_COL_WIDTH=30
include settings.mk targets.mk *.make
DISK_IMG = /var/local/disks/$(NAME).qcow2
REALPATH = $(shell ../_scripts/realpath.sh .)
NAME = $(shell basename "$(REALPATH)")

help:	## Show this help message
	@grep -hE '^\S+.*##.*' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_COL_WIDTH)s\033[0m %s\n", $$1, $$2}'


# NOTE: settings.mk must exist for automatic rebuild to work.
settings.mk: settings.sh ../settings.mk ../_scripts/make_settings.py ../_scripts/cluster-conf ## Transform settings.sh into settings.mk
	@echo "Updating settings.mk ..."
	@if test -f "$<"; then python ../_scripts/make_settings.py $< > $@ ; fi
	@../_scripts/cluster-conf $(NAME) >> $@
	@grep ^CLUSTER_ ../settings.mk >> $@
	@echo __SETTINGS_READY = true >> $@


targets.mk: *.make ## Rebuild default make targets
	@echo "Updating targets.mk ..."
	@$(shell which echo) -n "target_configs = " > $@
	@grep -hE '^\S+\.evt:' $^ | cut -f 1 -d : | grep -v % | grep -v ^# | tr \\n ' ' >> $@


update-configs: $(target_configs) | deploy.evt  ## (DEFAULT) Update all configured target configs


clean: settings.mk    ## Reset all target configs (use with care)
	rm -f $(target_configs)


ifneq ($(PHYS_HOST),)
deploy.evt: kvminit.evt
	touch "$@"

kvminit.evt:
	if test -n "$(PHYS_HOST)"; then \
		if test -f "kvminit.sh"; then \
			ping -qc 1 $(PHYS_HOST).$(CLUSTER_DOMAIN) && \
	        . $(VIRTUAL_ENV)/bin/activate && \
			fab -f $(MGMT_FABFILE) -u fabadmin -H $(PHYS_HOST).$(CLUSTER_DOMAIN) \
				deploy.putconf:"kvminit.sh,./,use_sudo=False" \
				deploy.putconf:"settings.mk,./,use_sudo=False" \
				run:"sed -i -e 's/ \= /\=/g' -e 's/\$$(CLUSTER_USER)/${CLUSTER_USER}/g' settings.mk" \
				sudo:"bash kvminit.sh" \
				run:"rm kvminit.sh settings.mk" ;\
		else \
			ping -qc 1 $(PHYS_HOST).$(CLUSTER_DOMAIN) && \
    	    . $(VIRTUAL_ENV)/bin/activate && \
			fab -f $(MGMT_FABFILE) -u fabadmin -H $(PHYS_HOST).$(CLUSTER_DOMAIN) \
				libvirtctl.create:"$(NAME),$(KVM_BRIDGE),$(MAC_ADDRESS),$(DISK),$(MEMORY),$(CPU_COUNT)" ;\
        fi \
	fi
	touch "$@"
else
deploy.evt: 
	touch "$@"
endif

