#
# Add an additional virtual disk (vdb) for data storage and backup;
# use LVM volume as a backing store.
# Note that, unlike vdb_data.make; this file DOES NOT format the
#	attached device.
#
# Standard inputs::
#   VIRTUAL_ENV, MGMT_FABFILE, FQDN, NAME, DOMAIN, PHYS_HOST
#
# Additional inputs::
#	HOST_VOLUME_GROUP - the volume group on the host.  Must already exist.
#   HOST_VOLUME_NAME - the name used for both the logical.
#	HOST_VOLUME_EXTENTS - the size of the vdb volume, in extents
#	 Calculate extents as VOLUME_SIZE(in G)*256-1
#

include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME DOMAIN PHYS_HOST)
# Required additional variables:
$(call check_defined, HOST_VOLUME_GROUP HOST_VOLUME_NAME HOST_VOLUME_EXTENTS)



# NB: virsh attach-disk reformats to raw, unless you use --type qcow2
#	https://serverfault.com/a/457259
vdb_lvm_device.evt: | kvminit.evt	## Create a vdb data device for the VM
	ping -qc 1 $(PHYS_HOST).$(DOMAIN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(PHYS_HOST).$(DOMAIN) \
		sudo:'if ! /sbin/lvdisplay /dev/$(HOST_VOLUME_GROUP)/$(HOST_VOLUME_NAME); then /sbin/lvcreate -l $(HOST_VOLUME_EXTENTS) -n $(HOST_VOLUME_NAME) $(HOST_VOLUME_GROUP); fi' \
		run:"echo \"<disk type\='block' device\='disk'><driver name\='qemu' type\='raw' cache\='none'/><source dev\='/dev/$(HOST_VOLUME_GROUP)/$(HOST_VOLUME_NAME)'/><target dev\='vdb' bus\='virtio'/></disk>\" > $(NAME)-data.xml" \
		sudo:'if ! virsh domblklist $(NAME) | grep $(NAME)-data; then virsh attach-device --domain $(NAME) --file $(NAME)-data.xml --persistent; fi' \
		run:'rm $(NAME)-data.xml'
	touch "$@"

# for when disk sizes change...
#		sudo:'virsh qemu-monitor-command $(NAME) --hmp "info block"' \
#		sudo:'virsh qemu-monitor-command $(NAME) --hmp "block_resize drive-virtio-disk1 $(VOLUME_SIZE)"'
