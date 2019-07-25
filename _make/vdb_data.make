#
# Add an additional virtual disk (vdb) for data storage and backup.
#
# Standard inputs::
#   VIRTUAL_ENV, MGMT_FABFILE, FQDN, NAME, DOMAIN, PHYS_HOST
#
# Additional inputs::
#   VOLUME_NAME - the name used for both the data logical volume and
#                   filesystem label that it gets formatted with.
#   VOLUME_ROOT - the location in the VM's filesystem this additional
#                   volume will be mounted at.
#	VOLUME_SIZE - the size of the vdb volume, i.e., "100G".
#

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME DOMAIN PHYS_HOST)
# Required additional variables:
$(call check_defined, VOLUME_NAME VOLUME_ROOT VOLUME_SIZE VOLUME_EXTENTS)




# NOTE: Really, this should check if VOLUME_ROOT already exists
#	before mkdir; and if so check if it contains anything;
#	if it does, this should setup a diversion, copy the existing content
#	and then setup the mount proper.
vdb_data.evt: | vdb_device.evt fabadmin.evt	## Initialize and mount the vdb data device
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if ! /sbin/pvdisplay /dev/vdb; then /sbin/pvcreate /dev/vdb; fi' \
		sudo:'if ! /sbin/vgdisplay data; then /sbin/vgcreate data /dev/vdb; fi' \
		sudo:'if ! /sbin/lvdisplay /dev/data/$(VOLUME_NAME); then /sbin/lvcreate -l $(VOLUME_EXTENTS) -n $(VOLUME_NAME) data; fi' \
		sudo:'if ! lsblk -f /dev/data/$(VOLUME_NAME) | grep ext4; then mkfs.ext4 -v -m .01 -b 4096 -L $(VOLUME_NAME)  /dev/data/$(VOLUME_NAME); fi' \
		sudo:'mkdir -p $(VOLUME_ROOT)' \
		sudo:'if ! mount | grep $(VOLUME_ROOT); then mount /dev/data/$(VOLUME_NAME) $(VOLUME_ROOT); fi' \
		sudo:'if ! grep $(VOLUME_ROOT) /etc/fstab; then echo "LABEL\=$(VOLUME_NAME)  $(VOLUME_ROOT)   ext4    defaults    0   1" >> /etc/fstab; fi'
	touch "$@"


# NB: virsh attach-disk reformats to raw, unless you use --type qcow2
#	https://serverfault.com/a/457259
vdb_device.evt: | kvminit.evt	## Create a vdb data device for the VM
	ping -qc 1 $(PHYS_HOST).$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(PHYS_HOST).$(DOMAIN) \
		sudo:'/usr/bin/qemu-img create -f qcow2 -o lazy_refcounts\=on\,preallocation\=metadata "/var/local/disks/$(NAME)-data.qcow2" $(VOLUME_SIZE)' \
		run:"echo \"<disk type\='file' device\='disk'><driver name\='qemu' type\='qcow2'/><source file\='/var/local/disks/$(NAME)-data.qcow2' cache\='none'/><target dev\='vdb' bus\='virtio'/></disk>\" > $(NAME)-data.xml" \
		sudo:'if ! virsh domblklist $(NAME) | grep $(NAME)-data; then virsh attach-device --domain $(NAME) --file $(NAME)-data.xml --persistent; fi' \
		sudo:'/usr/bin/qemu-img info "/var/local/disks/$(NAME)-data.qcow2" | grep "file format: qcow2"' \
		run:'rm $(NAME)-data.xml'
	touch "$@"

# for when disk sizes change...
#		sudo:'virsh qemu-monitor-command $(NAME) --hmp "info block"' \
#		sudo:'virsh qemu-monitor-command $(NAME) --hmp "block_resize drive-virtio-disk1 $(VOLUME_SIZE)"'
