===================================================
mcp - Automate VM Administration and Monitoring
===================================================

Hostname:
    ``mcp.example.com`` (internal only)
VM network IP:
    192.168.1.5
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS

.. note::
   This VM is named after the antagonist in the movie TRON,
   the Master Control Program.

Purpose
---------

This VM provides a standard location for performing maintenance
on the VM cluster (the VM host should only be used for 
provisioning and deployment).

It also provides the `Nagios`_ server for system monitoring and
alerts.

.. note::
    Web interface admin user is ``nagiosadmin`` with password generated
    for this website using Master Password.

.. note::
   Through the ``dispatch`` VM, the Nagios web interface is available 
   at the urn ``/cluster/status``.
   


Services
---------

Nagios:
    System monitoring for the entire cluster.


Nagios users
-------------

To add a user, run::

    htpasswd htpasswd.users <username>
    
and ensure that you update the ``cgi.cfg`` file with the appropriate 
access for that user.  (The number of users for nagios should be very small.)
Alternately, a user can be set as a contact for a service/host/etc.


Using mcp for routine updates
-------------------------------

Connect to ``mcp``.  This must done by tunnelling through ``kvm0``.
One approach is to use a bash function like the following::

    function ssh-example-kvm0() 
    {
        if [ "$1" == "" ]; then
            ssh -At CLUSTER_USER@kvm0.example.com screen -dRR
        else
            ssh -At CLUSTER_USER@kvm0.example.com ssh -t "$1" screen -dRR
        fi
    }

This function makes use of the ``screen`` commmand to ensure
that ssh disconnects do not interrupt anything important.
Connect to ``mcp`` using the command::

    ssh-example-kvm0 mcp

Then, on ``mcp``, use the command::

    fab-safeupdate
    
The ``fab-safeupdate`` command (another bash function) will update
the VMs and reboot as necessary, and then will update the ``kvm0`` host
but will **not** reboot it.  Rebooting the ``kvm0`` host should only be
done with planning on notification of people responsible for *all* VMs
hosted on the system (e.g., Khosrow).

.. note:: 
   On ``kvm0``, you may need to restart the ``libvirtd`` service
   if the underlying libraries are updated.
   This **does not** affect running virtual machines,
   so it is *safe* to restart this service.
   
        Restarting libvirtd does not impact running guests.
        
        -- man (8) libvirtd



.. _Nagios: https://www.nagios.org 

   
