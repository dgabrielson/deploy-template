include settings.mk

.PHONY: iso help clean
.DEFAULT_GOAL := help
HELP_COL_WIDTH=16


preseed.cfg: preseed.cfg.tmpl preseed.part.tmpl preseed.user.tmpl settings.mk	## Construct the preseed file.
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g' -e 's/CLUSTER_ADMIN/$(CLUSTER_USER)/g' preseed.cfg.tmpl > $@
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g' -e 's/CLUSTER_ADMIN/$(CLUSTER_USER)/g'  preseed.part.tmpl >> $@
	sed -e 's/example.com/$(CLUSTER_DOMAIN)/g' -e 's/CLUSTER_ADMIN/$(CLUSTER_USER)/g' preseed.user.tmpl >> $@


profiles/kvm-host.preseed: preseed.cfg
	@mkdir -p $(@D)
	cp $+ $@

	
my-sdd.conf:
	@echo 'locale=en_CA.UTF-8' > $@
	@echo 'profiles="kvm-host"' >> $@
	@echo 'auto_profiles="kvm-host"' >> $@
	@echo 'debian_mirror="http://ftp.ca.debian.org/debian"' >> $@
	@echo 'export KERNEL_PARAMS="auto=true priority=critical keymap=us interface=eth0 preseed/file=/cdrom/simple-sdd/default.preseed"' >> $@


iso: my-sdd.conf profiles/kvm-host.preseed	## Make the ISO file using simple-cdd
	build-simple-cdd --conf ./my-sdd.conf
	
	
help:   ## Show this help message
	@grep -hE '^\S+.*##.*' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-$(HELP_COL_WIDTH)s\033[0m %s\n", $$1, $$2}'


clean:	## Cleanup
	rm -rf my-sdd.conf preseed.cfg profiles build
