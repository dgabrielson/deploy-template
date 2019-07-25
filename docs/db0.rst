===================================================
db0 - Database storage
===================================================

Hostname:
    ``db0.example.com`` (internal only)
VM network IP:
    192.168.1.15
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS

.. note::
   A future project involves setting up a mirrored database cluster
   with an additional ``db1`` node.
   However, until there is an additional VM host (``kvm1``?)
   on which to host ``db1``, it seems unlikely that there will be
   any real benefit to a database cluster.
   This project requires further investigation and research.

Purpose
---------

Provide structured database services to other VMs.

.. note::
   The database is backed up to the ``files`` VM.
   This is handled via a cronjob which fires at 04:00 daily and
   dumps all of the databases over NFS.


Services
---------

postgresql
    A database server.