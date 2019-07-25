====================================================
exampleapp - Primary web application for example website
====================================================

Hostname:
    ``exampleapp.example.com`` (internal only)
VM network IP:
    192.168.1.55
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS


.. note::
   Through the ``dispatch`` VM, this interface is available 
   at the urn ``/``.

Services
---------

`uwsgi`_ Emperor:
    An application server for the web interface.
    

.. _uwsgi: http://uwsgi-docs.readthedocs.org