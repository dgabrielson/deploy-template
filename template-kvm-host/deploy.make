deploy_rm_extra.evt: 
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(CLUSTER_USER) -H $(FQDN) \
		sudo:"if mount | grep /var/extra; then umount /var/extra; fi" \
		sudo:"if test -d /var/extra; then rmdir /var/extra; fi" \
		sudo:"if lvdisplay /dev/vg0/extra; then lvremove -f /dev/vg0/extra; fi" \
		sudo:"if grep ^/dev/mapper/vg0-extra /etc/fstab; then sed -i 's%^/dev/mapper/vg0-extra%#/dev/mapper/vg0-extra%' /etc/fstab; fi"
	touch "$@"


deploy_install.evt: deploy_core.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(CLUSTER_USER) -H $(FQDN) \
		deploy.kvm.install
	touch "$@"


deploy_venv.evt: deploy_install.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(CLUSTER_USER) -H $(FQDN) \
		deploy.pyenv.prep:"minimal=True" \
		sudo:"apt-get install -y -qq libffi-dev libssl-dev" \
		deploy.pyenv.create:"fab,../../mgmt-fab/requirements.txt,local=True"
	touch "$@"
