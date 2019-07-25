=========================================
logapp - Web interface for log database
=========================================

Hostname:
    ``logapp.example.com`` (internal only)
VM network IP:
    192.168.1.45
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS


Purpose
---------

Provide a web interface to the central logging information.

.. note::
   This VM only provides the web interface to the database.
   The VM ``logsrv`` is responsible for handling the syslog relay.
   
.. note::
    Web interface admin user is ``CLUSTER_USER`` with password generated
    for this website using Master Password.
    
.. note::
   Through the ``dispatch`` VM, this interface is available 
   at the urn ``/cluster/syslog``.

Services
---------

`uwsgi`_ Emperor:
    An application server for the web interface.
    

.. _uwsgi: http://uwsgi-docs.readthedocs.org