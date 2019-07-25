================================
logsrv - Cluster wide logging
================================

Hostname:
    ``logsrv.example.com`` (internal only)
VM network IP:
    192.168.1.25
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS


Purpose
---------

Provide central logging for the entire cluster.

.. note::
   This VM only provides the syslog relay to the database.
   The VM ``logapp`` is responsible for providing the 
   web interface.
   
This VM runs a cronjob every day at midnight which removes
log entries received more than 60 days old from the database.
(These entries are not archived.)

Services
---------

rsyslog
    An rsyslog instance which accept system logging information
    and stores it in the database.