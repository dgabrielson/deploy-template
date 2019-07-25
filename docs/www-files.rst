=========================================
www-files - Static file access via http
=========================================

Hostname:
    ``www-files.example.com`` (internal only)
VM network IP:
    192.168.1.56
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS


This VM provides mediated *read only* access to the ``exampleapp`` file store
area of the ``files`` VM.

   
.. todo::
   Diagram the dispatch urns to file locations (? if needed).
   
.. note::
   Through the ``dispatch`` VM, requests to the urns
   ``/media`` and ``/static`` are routed here.
   ``/cluster/syslog/static`` also routes here.


Services
---------
nginx
    Delivers static file content.

