
CERTS = dhparams.pem.evt nginx-cert.crt.evt nginx-cert.key.evt


payload/dhparams.pem:
	openssl dhparam -out "$@" 2048


$(CERTS): %.evt: payload/%
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/var/www/ssl/,use_sudo=True" \
	touch "$@"
	

nginx-cert.evt: $(CERTS) | fabadmin.evt	## Update nginx configuration.
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"killall -HUP nginx"
	touch "$@"
