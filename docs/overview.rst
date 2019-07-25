Server Configuration, Updates, & Documentation
==============================================

- Makefile / Fabric based
- Works on the entire cluster/group of machines
- All changes from baseline installs are stored in code / reproducible
- All configuration info stored in version control
- "DevOps approach"
- Expectations: some familiarity with make, python, and Unix/Linux system administration.

In this document; "cluster" is used to mean any group of machines which are managed together.

``~/src/cluster-deploy/<group>``

Current groups:
- gauss: Math Compute Cluster
- home: My house config
- math: Primary math group; server in physics data room 108 Allen
- skaro: Stats Compute Cluster (but note head node [bayes] is configured as part of stats, below)
- stats: Primary stats group; servers in 346 Machray Hall.

Also at this level:
- template: A base template to instantiate new groups/maintain common build system.  (Makefile actions always update the build system when the "DEPLOY_TEMPLATE" variable is set in settings.mk
- mgmt-fab: The management fabric library that individual makefiles can rely on to automate remote server actions.  This currently is implemented in Fabric1.  Needs to be updated for Fabric2.  See http://docs.fabfile.org/en/latest/ 

General layout of each cluster:
--------------------------------
Makefile: 
	(build system) top level makefile.  
	All makefiles use "help" as a default target.
_docker/: 
	individual docker machine configs, if any.  
_make/: 
	(build system) individual target makefiles.
_nrpe/: 
	(build system) common nrpe (nagios client) check scripts.
_scripts/: 
	(build system) common helper scripts.
_sudoers/: 
	(build system) common sudoers files.
cluster.conf: 
	(generated) amalgamated host information.
cnames.conf: 
	(input) host name aliases.  
	Fields: host alias [alias1 […]]
common_settings.sh: 
	(input) used by individual machine configs for common settings.
hosts.extra: 
	(generated) an "extra" addition for /etc/hosts the defines information for the entire cluster.
local_extras.mk: 
	(input) declare extra targets, dependencies and make rules.
phys-hosts.conf: 
	(input) declare physical machines in the cluster.  
	Tab delimited.  
	Fields: name	mac-address	ip-address	eth-name	services
settings.mk: 
	(input) declare top-level cluster configuration
unmgd-hosts.conf:
	(input) declare hosts which are fully unmanaged by the cluster.  
	Useful for declaring "extra" machines/appliances that will not be configured (additional interfaces; remote access consoles; etc.). 
	Tab delimited.
	Fields: name	mac-address	ip-address	services
virt-hosts.conf: 
	(input) declare virtual (KVM) machines in the cluster (not containers).  
	Tab delimited.  
	Fields: name  mac-address ip-address  physhost	memory(m)  disk(g)  cpu-count    services
machine_cname/: 
	Individual machine configurations.  
	This folder contains makefile which are typically symbolic links back to ../_make/ (unless custom modifications are required).
	Makefile at this level should always symlink to ``../_make/Hostmain.make``.
machine_cname/payload/: 
	individual configs that are placed on the remote machine.


NOTE: currently transitioning from a fully KVM based clusters to hybrid KVM/containerized clusters. (Primarily on math.)

General Workflow:
-----------------
- Edit files as needed.
- If any top level files are changed (e.g., virt-hosts.conf) run "make local" (rebuild all local files).
- Run "make update".  This will update the remote cluster appropriately.  Note that if CLUSTER_GATEWAY is set in "settings.mk" then the cluster folder and mgmt-fab are staged on the remote machine identified by CLUSTER_DST and "make update" is re-run from there. (ssh tunnelling for the win!)
- Ensure that changes are effective/successful.  Once that has been verified, commit the change and push the repo to a private location for backup purposes.


