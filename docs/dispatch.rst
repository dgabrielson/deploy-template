=============================================================
dispatch - Service dispatcher for VM cluster
=============================================================

Hostname:
    ``dispatch.example.com`` (internal only)
    ``www.example.com`` (external only)
VM network IP:
    192.168.1.250
External IP:
    130.179.75.62
Eternal interface MAC: 
    52:54:00:60:ff:4a
Hosted on:
    ``kvm0``
Operating system:
    Ubuntu LTS
    

Services
---------
iptables
    Handles DNAT traffic throughout the cluster based on target ports.
    Note that any DNAT'd traffic will appear to the rest of the cluster
    as originating from the VM network IP of this machine, and *not*
    the original source IP.

nginx
    Handles traffic to ``www.example.com`` and unraps SSL
    before re-routing traffic based on incoming urn.
    Nginx is used, rather than port forwarding, due to the limitations of
    iptables maintaining original source IPs.

Note that ssh is **not** enabled on the external interface of this machine.


SSL by default
---------------

.. todo::
   Discuss benefits, including HTTP2.



Dispatching
------------

www: 80,443
    Handled by nginx
    

mail: 25, 465, 587, 993
    Handled by iptables.
    This is a transitionary port for exposing the internal IMAP running on 
    the ``mail`` VM.  This *could* eventually be exposed by routing 
    traffic for a public IP ``mail.example.com`` server, in which
    case the port forwarding should be 25, 465, 587 (smtp) and 993 (imap).
    In this case, the ``mail`` VM will need a proper SSL certificate 
    for modern compatibility.

    .. todo::
       iptables forwarding as currently implemented hides the external 
       source address from the internal VM.  It would be better to 
       see the true source address with internal VM routing.