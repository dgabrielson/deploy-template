=================================
kvm0 - Virtual Machine Host
=================================

Hostname:
    kvm0.example.com
Hardware:
    Dell PowerEdge R410
RAM:
    16 Gb
Disk:
    500 Gb RAID-1 mirror
RAC Host:
    kvm0-rac.example.com
Operating system:
    Debian/stable
Configuration:
    kvm host
    

Provisioning and Installation
------------------------------
By Debian/stable net install CD, with a USB stick for ``bnx2`` firmware.

Normally, this machine would have been setup via the RAC using
virtual media, however due to the non-open ``bnx2`` network drivers
required installation was done at the machine.

This hardware is physically located in the physics server room,
1XX Allen.  It is attached to a UPS.


Deployment
---------------
See ``example-deploy/kvm0/deploy.sh``, and ``example-deploy/kvm0/debian-manual.txt``.


.. todo::
   Describe the manual steps required before the deployment script is run.
   

The External Network bridge
-----------------------------
Top hardware ethernet port.
Network device ``br0``.  
VMs requiring external IP addresses need to be bound to this bridge.

The RAC module is also bound to this ethernet port.


The VM Network bridge
-----------------------
Bottom hardware ethernet port.
Network Device ``br1``.
IP address block 192.168.1.0/24.
The bridge itself has address 192.168.1.2 (.1 is provided by the provision VM
which actually handles NAT from this network to the external internet).


Pre-provisioning
------------------
The network addresses and MAC addresses for VMs are pre-allocated
so that configuration and dependencies can be planned in advance,
and so that network resources can be handled via dhcp.

This is handled by the file ``example-deploy/cluster.conf``; if this
file is updated or changed then it is necessary to change to the
``example-deploy`` directory and run::

    make
    
Which will update certain configuration files.
It's also a good idea to ensure that your ``~/.ssh/config`` file is up 
to date::

    make ~/.ssh/config

*If* there are already existing VMs, it will also be necessary to update
the configurations for ``kvm0``, ``provision``, and ``mcp``
(make sure the ``mgmt-fab`` environment is available first)::

    workon fab; cd -
    for m in kvm0 provision mcp; do ./${m}/update_confs.sh; done
    
The cluster.conf file is a tab-delimited text file with each machine
on one line, with the fields: *name*, *MAC address*, *IP address*, *RAM*, 
*disk size*, *cpu count*, and *hostgroups*.

IP Address:
    is the address of the VM on the VM network.
    
RAM:
    is specified in Megabytes.
    
disk size:
    is specified in Gibabytes.
    
hostgroups:
    is a (possibly empty) list of hostgroups defined for nagios monitoring.
    See ``mcp/conf.d/cluster-hostgroups.cfg``.



Thin provisioning
--------------------
Due to the relatively constrained nature of both the RAM and disk storage
of this hardware, both RAM and disk of VMs are "thin provisioned" or
"over provisioned".  
This is the default for RAM with KVM, however the disks are allocated
as no preallocation qcow2 images in ``/var/local/disks``.
This storage area is a separate LVM backed partition which has been
initially allocated for 250 Gb of storage.  
There is a slight performance penalty in having the disk images
grow on demand, however it would require 300 Gb for the initial
allocation which would leave little to no room for backups of the
VM disks.

Should the hardware situation change, it may be worth converting
the VM disk images to the pre-allocated qcow2 format.
See::

    man qemu-img
    
for details on how this can be accomplished.


Provisioning, deployment, and configuration of VMs
---------------------------------------------------

    Server provisioning is a set of actions to prepare a server with 
    appropriate systems, data and software, and make it ready for 
    network operation.
    
    -- `Wikipedia`_, retrieved November 19, 2015.

*Provisioning*, in this document, refers specifically to allocating the 
initial resources for the virtual machine, as well as installing a 
standard base operating system.
For VM ``foo``, this is done via the script ``example-deploy/foo/kvm-setup.sh``.
The ``provision`` VM aids this process by providing both a PXE environment
and a ``preseed.cfg`` url to instantiate Ubuntu LTS VMs with no interaction.

*Deployment*, in the document, refers to taking this standard operating
system image and installing software and add/modifying configuration files
in order to take the VM to a fully operational state.
For VM ``foo``, this is done via the script ``example-deploy/foo/deploy.sh``.
Additionally, it is sometimes necessary to update only the configuration
on the VM (since it is already deployed), and so there is also a 
``example-deploy/foo/update_confs.sh`` script to accomplish this.

Order
------
.. important::
   The order of VMs presented in this document is the order in which 
   they must be deployed, due to inter-VM dependencies.

Backups
--------

For now, backups are being done via KVM/QEMU snapshots to 
``/var/local/disks/backup/``.  Only one backup is kept here –
The backup script can be found at 
``/usr/local/sbin/vm-backup.sh``.

A second backup script, ``/usr/local/sbin/vm-backup-external.sh``
performs a staged backup to a NAS appliance in Khosrow's office via NFS.



.. _Wikipedia: https://en.wikipedia.org/wiki/Provisioning#Server_provisioning
.. _LVM snapshots: http://www.tldp.org/HOWTO/LVM-HOWTO/snapshots_backup.html
.. _virt-backup script: http://repo.firewall-services.com/misc/virt/virt-backup.pl

