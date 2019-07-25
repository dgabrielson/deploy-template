# these should be defined in phys-hosts.conf
PHYSICAL_HOSTS = kvm0 
# these should be defined in virt-hosts.conf
VIRTUAL_HOSTS = provision mcp files db0 logsrv mail logapp www-files dispatch

# cluster core config
CLUSTER_USER = clusteradmin
CLUSTER_DOMAIN = example.com
CLUSTER_GATEWAY = $(CLUSTER_USER)@external_host_or_ip
# note: cluster dst **must** be present in hosts list.
CLUSTER_DST = mcp

# setting this allows for common code to get updated from the master copy.
# DEPLOY_TEMPLATE = ../cluster-deploy-template