=============
Introduction
=============

This documentation describes the deployment process for the
CLUSTER OWNER infrastructure systems.

Infrastructure systems (a.k.a., "servers") are defined for
purposes of this document to be any system not used as a
desktop or laptop workstation, that provide services either
for other systems or to users.

This documentation is part of the ``example-deploy`` archive,
which contains scripts which are used to automated deployment.
There is an additional archive ``mgmt-fab`` (management fabric),
which is also required for deployments.


Management Fabric
------------------
    "`Fabric`_ is a Python library and command-line tool for streamlining 
    the use of SSH for application deployment or systems administration tasks."
    
    -- Fabric documentation

It's best to use a `Python virtual environment`_ when deploying.
All of the deployment scripts are written assuming that the 
``mgmt-fab`` archive exists at the same directory level as the 
``example-deploy`` archive.



Administrative access
----------------------
`Master Password`_ is used to manage passwords for the ``CLUSTER_USER`` 
account (the author's account, which normally has privileged access
on deployed systems).  The account information for Master Password
is stored in **the EXAMPLE envelope**.

Systems deployed using the example ``preseed.cfg`` will be created
with the user ``CLUSTER_USER`` instead of ``CLUSTER_USER``
which has the standard password also
found in **the example envelope**.

For reference, the ``provision/payload/preseed.user.tmpl`` 
contains the hashed 
user password (and should be considered a "protected resource").
To generate the password hash for use in this file, use the command::

    mkpasswd -m sha-512
    
and update the value of the ``passwd/user-password-crypted``.


.. _Fabric: http://fabric.readthedocs.org
.. _Master Password: http://masterpasswordapp.com
.. _Python virtual environment: http://docs.python-guide.org/en/latest/dev/virtualenvs/