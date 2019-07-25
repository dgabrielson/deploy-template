==============================
files - Provide file storage
==============================

Hostname:
    ``files.example.com`` (internal only)
VM network IP:
    192.168.1.10
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS


Purpose
---------

This VM provides central file storage to other VMs in the cluster.
Having VMs store static state data on a central system allows
for a common (larger) storage pool and for the storage to be
easily backed up.

Additionally, should other storage solutions present itself,
having this isolated allows for easier future migration e.g.,
to dedicated storage hardware, or redundant storage solutions 
such as `GlusterFS`_.


Services
---------

nrpe
    Allow nagios server monitoring.

nfsd
    Export storage to the VM subnet.

   
.. _GlusterFS: http://www.gluster.org