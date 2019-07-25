
include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN NAME)

# Additional required variables:
$(call check_defined, SSHD_PORT SSHD_LISTEN_ADDRESS)



sshd_config.evt: | fabadmin.evt	## Update sshd_config
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:'if grep ^#Port /etc/ssh/sshd_config; then sed -i~ -e "s/#Port /Port /" /etc/ssh/sshd_config ; fi' \
		sudo:'sed -i~ -e "s/^Port ..*/Port $(SSHD_PORT)/" /etc/ssh/sshd_config' \
		sudo:'if grep ^#ListenAddress\\ 0.0.0.0 /etc/ssh/sshd_config; then sed -i~ -e "s/#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/" /etc/ssh/sshd_config ; fi' \
		sudo:'sed -i~ -e "s/^ListenAddress ..*/ListenAddress $(SSHD_LISTEN_ADDRESS)/" /etc/ssh/sshd_config' \
		sudo:'systemctl reload ssh'
	touch "$@"
