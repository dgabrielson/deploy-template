
include ../_make/nagios_check_memory.make
include ../_make/nagios_check_swap.make
include ../_make/nagios_needrestart.make

nrpe_std_checks.evt: \
	nagios_check_memory.evt \
	nagios_check_swap.evt \
	nagios_needrestart.evt \
	sudoers_needrestart.evt
	touch $@
