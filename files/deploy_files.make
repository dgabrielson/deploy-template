
deploy_extras.evt: | vdb_data.evt deploy.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"chown :$(DEPLOY_ADMIN) $(STORAGE_ROOT)" \
		sudo:"mkdir -p $(STORAGE_ROOT)/{host\,home}" \
		sudo:"chown $(DEPLOY_ADMIN):$(DEPLOY_ADMIN) $(STORAGE_ROOT)/{host\,home}" \
		sudo:"chmod -R g+wX\,a+rX $(STORAGE_ROOT)" \
		deploy.nfs_server:"$(NFS_SERVER)"
	touch "$@"



vdb_data.evt: | vdb_device.evt fabadmin.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if ! /sbin/pvdisplay /dev/vdb; then /sbin/pvcreate /dev/vdb; fi' \
		sudo:'if ! /sbin/vgdisplay data; then /sbin/vgcreate data /dev/vdb; fi' \
		sudo:'if ! /sbin/lvdisplay /dev/data/storage; then /sbin/lvcreate -l 25599 -n storage data; fi' \
		sudo:'if ! lsblk -f /dev/data/storage | grep ext4; then mkfs.ext4 -v -m .01 -b 4096 -L storage  /dev/data/storage; fi' \
		sudo:'mkdir -p $(STORAGE_ROOT)' \
		sudo:'if ! mount | grep $(STORAGE_ROOT); then mount /dev/data/storage $(STORAGE_ROOT); fi' \
		sudo:'if ! grep $(STORAGE_ROOT) /etc/fstab; then echo "LABEL\=storage  $(STORAGE_ROOT)   ext4    defaults    0   1" >> /etc/fstab; fi' 
	touch "$@"



vdb_device.evt: | kvminit.evt
	ping -qc 1 $(PHYS_HOST).$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(PHYS_HOST).$(DOMAIN) \
		sudo:'/usr/bin/qemu-img create -f qcow2 -o preallocation\=off "/var/local/disks/files-data.qcow2" 100G' \
		sudo:'if ! virsh domblklist files | grep files-data; then virsh attach-disk files --source /var/local/disks/files-data.qcow2 --target vdb --persistent; fi' \
		sudo:'virsh qemu-monitor-command files --hmp "info block"' \
		sudo:'virsh qemu-monitor-command files --hmp "block_resize drive-virtio-disk1 100G"'
	touch "$@"
