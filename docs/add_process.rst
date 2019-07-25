================
Adding a new VM
================

This is a process document for adding new VMs into the cluster.

This document assumes that the reader is preparing a new VM in a branch of
the ``example-deploy`` repository on their own machine.


1. Determine initial requirements for VM (RAM, disk, CPU).
#. Determine hostname and outline of initial configuration.
#. Add a line for this VM in the top-level
   ``cluster.conf`` file.  *Remember that this file is tab delimited!*
   (Ensure your editor does not replace tabs with spaces.)
   Use the ``_scripts/mac-generator.sh`` script to generate the MAC address.
   IP addresses are chosen manually, but ensure there are no duplicates.
#. Create a directory for the new machine (usually, copy and modify an existing one).
   The directory name should be the (short) hostname of the new VM.
#. Edit the directory information for the new VM.
   At a minimum, each VM directory should contain four files:
   ``deploy.sh``, ``kvm-setup.sh``, ``settings.sh``, and ``update_confs.sh``.
   Additionally, if the machine is going to be monitored, there should also be
   a ``local_nrpe.cfg``.
   Any other configuration files for that VM should be placed here as well.
#. If necessary, update any other VM configurations which are impacted by
   adding this new VM (e.g., ``dispatch`` for adding web service redirections).
#. Prepare a documentation file for the VM (under ``docs/``), 
   add the VM documentation file to ``docs/virtual_machines.rst``, and
   symlink the documentation file into the VM directory.
#. Ensure that your current working directory is the top level of your local
   ``example-deploy`` repository.
#. Run ``make all docs-clean docs-html``.
#. Commit and push your changes: ``hg add && hg commit -m 'Update for VM <foo>' && hg push``
#. Update the ``kvm0`` distribution repository: ``./kvm0/update_confs.sh``.
#. Use ``ssh`` to connect to ``kvm0`` for deployment.
   On ``kvm0``, change to to the ``example-deploy`` repository.
#. Run the following to ensure supporting VMs are updated 
   (your VM may need additional supporting updates, e.g., to ``dispatch``):   
   ``for vm in logapp mcp provision; do ./${vm}/update_confs.sh; done``. 
#. For your new VM, run: ``./<foo>/kvm-setup.sh``. 
   This script allocates the disk for the VM, netboots via PXE from ``provision``,
   and sets a minimal Ubuntu LTS configuration with the ``CLUSTER_USER`` user 
   and ``ssh-server``.  Finally, it sets the VM to autostart, and it then runs the
   ``./<foo>/deploy.sh`` script to finish the VM deployment.

.. note:: This document assume that the VM will be hosted on ``kvm0``.
          The ``./<foo>/kvm-setup.sh`` **must** be run on the hosting hardware.


**Best practice**: have all of the actual machine values for other hosts,
passwords, and so on defined in ``settings.sh``; this way the other scripts
are maximally reusable.


