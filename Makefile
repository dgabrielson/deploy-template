
MAKEFILE_DIR := $(shell dirname $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(shell $(MAKEFILE_DIR)/_scripts/realpath.sh $(MAKEFILE_DIR))
DEPLOY_BASE := $(shell basename $(MAKEFILE_DIR))
PARENT_DIR := $(shell dirname $(MAKEFILE_DIR))
MGMTFAB_DIR = $(PARENT_DIR)/mgmt-fab

include $(MAKEFILE_DIR)/settings.mk

DOCS = docs
HOSTNAME = $(shell hostname -s)
HOSTS = $(PHYSICAL_HOSTS) $(VIRTUAL_HOSTS)
HOSTS_UPDATE = $(addsuffix -update, $(HOSTS))
HOSTS_KVMINIT = $(addsuffix -kvminit, $(HOSTS))
HOSTS_DEPLOY = $(addsuffix -deploy, $(HOSTS))
LOCAL = cluster.conf hosts.extra
RSYNC_FLAGS =  -au --delete-after --exclude .hg --exclude '*.evt' --exclude '*.pyc'
RSYNC_SRC = $(MAKEFILE_DIR) $(MGMTFAB_DIR)
SCRIPTS = _scripts/hosts.awk _scripts/nagios-hosts.awk _scripts/ssh_config.awk

HELP_COL_WIDTH=16
.DEFAULT_GOAL := help
.PHONY = help update $(HOSTS_UPDATE) update-all internal-rsync internal-update remote-rsync remote-update clean distclean

-include $(MAKEFILE_DIR)/local_extras.mk



help:	## Show this help message
	@grep -hE '^\S+.*##.*' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_COL_WIDTH)s\033[0m %s\n", $$1, $$2}'


scripts: $(BUILDSYS) $(SCRIPTS)


sublocal0: $(SCRIPTS) $(LOCAL)


sublocal1: sublocal0 $(LOCAL_EXTRAS)


local: sublocal1  ## Rebuild any cluster level data that's changed


clean:	## Remove any local build targets
	rm -f $(LOCAL) $(LOCAL_EXTRAS)


distclean: clean	## Remove local build targets, scripts, and event flags
	rm -f $(SCRIPTS)
	find . -name *.evt -type f -print0 | xargs -0 rm -f


cluster.conf: phys-hosts.conf unmgd-hosts.conf virt-hosts.conf
	python $(MAKEFILE_DIR)/_scripts/make-cluster.py $+ > $@


cluster_map.pdf: cluster.conf _scripts/cluster2dot.py	## Generate a PDF showing the relationship between physical and virtual machines.
	_scripts/cluster2dot.py | dot -Tpdf > $@


hosts.extra: cluster.conf cnames.conf a.conf _scripts/hosts.awk
	$(MAKEFILE_DIR)/_scripts/hosts.awk $< > $@.tmp1
	python $(MAKEFILE_DIR)/_scripts/add_a.py $@.tmp1 a.conf $(CLUSTER_DOMAIN) > $@.tmp2
	echo '#### begin generated hosts ####' > $@
	python $(MAKEFILE_DIR)/_scripts/add_cnames.py $@.tmp2 cnames.conf $(CLUSTER_DOMAIN) >> $@
	echo '#### end generated hosts ####' >> $@
	rm $@.tmp1 $@.tmp2


ssh-config.gen: cluster.conf _scripts/ssh_config.awk
	$(MAKEFILE_DIR)/_scripts/ssh_config.awk $< > $@


ssh-config.pre:
	sed -e '/#### begin cluster-deploy ssh config ####/,/#### end cluster-deploy ssh config ####/d' ~/.ssh/config > $@


~/.ssh/config: ssh-config.pre ssh-config.gen	## Set local ssh config from cluster config (will override existing)
	cat $+ > $@


docs-html:  ## Make the html documentation
	$(MAKE) -C $(DOCS) html


docs-pdf:     ## Make the pdf documentation
	$(MAKE) -C $(DOCS) latexpdf


docs-clean:
	$(MAKE) -C $(DOCS) clean


$(HOSTS_UPDATE): %-update: %
	$(MAKE) -C $(MAKEFILE_DIR)/$< update-configs


$(HOSTS_KVMINIT): %-kvminit: %
	# which kvm host is "$<" supposed to run on?
	# transfer system there, then do:
	$(MAKE) -C $(MAKEFILE_DIR)/$< kvminit.evt


$(HOSTS_DEPLOY): %-deploy: %
	$(MAKE) -C $(MAKEFILE_DIR)/$< deploy update-configs


update-all: $(HOSTS_UPDATE)


internal-rsync:
	rsync $(RSYNC_FLAGS) $(RSYNC_SRC) $(CLUSTER_USER)@$(CLUSTER_DST):


remote-rsync:
	rsync $(RSYNC_FLAGS) -e "ssh -A $(CLUSTER_GATEWAY) ssh" $(RSYNC_SRC) $(CLUSTER_USER)@$(CLUSTER_DST):


internal-update-all:
	ssh -t $(CLUSTER_USER)@$(CLUSTER_DST) make -C $(DEPLOY_BASE) update


remote-update-all:
	ssh -At $(CLUSTER_GATEWAY) ssh -t $(CLUSTER_USER)@$(CLUSTER_DST) make -C $(DEPLOY_BASE) update


# different update actions depend on which host make is being run on.
ifeq ($(filter $(HOSTNAME), $(HOSTS)), $(HOSTNAME))
# on the remote side we don't worry about updating the build system
DEPLOY_TEMPLATE :=
ifeq ($(HOSTNAME),$(CLUSTER_DST))
UPDATE_DEPS := update-all
else
UPDATE_DEPS := internal-rsync internal-update-all
endif
else
ifeq ($(CLUSTER_DST), )
UPDATE_DEPS := update-all
else
UPDATE_DEPS := remote-rsync remote-update-all
endif
endif

update: $(UPDATE_DEPS) local	## Update all cluster hosts configurations


setup-host:	## run this from a host directory to initialize the host for the make system
	test -f settings.sh	# sanity check: are we in a host directory?
	test ! -f Makefile	# sanity check: have we already been initialized?
	python ../_scripts/make_settings.py settings.sh | grep '^VIRTUAL_ENV ='  # without this setting, everything will fail.
	python ../_scripts/make_settings.py settings.sh | grep '^MGMT_FABFILE ='  # without this setting, everything will fail.
	python ../_scripts/make_settings.py settings.sh | grep '^DEPLOY_ADMIN ='  # without this setting, everything will fail.
	python ../_scripts/make_settings.py settings.sh | grep '^FQDN ='  # without this setting, everything will fail.
	python ../_scripts/make_settings.py settings.sh | grep '^NAME ='  # without this setting, things will fail.
	ln -s ../_make/Hostmain.make Makefile
	ln -s ../_make/deploy_core.make
	ln -s ../_make/fabadmin.make
	mkdir -p payload
	if test -f local_nrpe.cfg ; then mv local_nrpe.cfg payload/ ; fi
	if test -f payload/local_nrpe.cfg ; then ln -s ../_make/local_nrpe.make; fi


$(SCRIPTS): %.awk: %.awk.tmpl settings.mk
	# Need to exclude BUILDSYS tmpl files...
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g'  -e 's/CLUSTERADMIN/$(CLUSTER_USER)/g'  $< > $@
	chmod +x $@



ifneq ($(DEPLOY_TEMPLATE),)

BUILDSYS := _make _nrpe _scripts _sudoers
FOUND_BUILDSYS_FILES := $(shell find $(BUILDSYS) -type f -print)
BUILDSYS_FILES = $(filter-out $(SCRIPTS), $(FOUND_BUILDSYS_FILES))


$(BUILDSYS_FILES): %: $(DEPLOY_TEMPLATE)/%
	@echo "Updating build system - changed files"
	cp $< $@


$(BUILDSYS): %: $(DEPLOY_TEMPLATE)/%
	@echo "Updating build system - add or deleted files"
	rsync $(RSYNC_FLAGS) $</* $@/
	touch $@


Makefile: $(DEPLOY_TEMPLATE)/Makefile $(BUILDSYS) $(BUILDSYS_FILES)
	@echo "Updating Makefile"
	cp $< $@

endif
