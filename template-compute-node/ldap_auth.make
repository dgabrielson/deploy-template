include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



ldap_auth.evt: payload/nslcd.conf | fabadmin.evt       ## Update /var/www/html/index.html
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"DEBIAN_FRONTEND\=noninteractive apt install -yq libnss-ldapd" \
		deploy.putconf:"$<,/etc/,use_sudo=True,mode=0640" \
		sudo:"if ! grep ^passwd:.*ldap$$ /etc/nsswitch.conf; then sed -i~ -e '/^passwd:/ s/$$/ ldap/' /etc/nsswitch.conf; fi" \
		sudo:"if ! grep ^group:.*ldap$$ /etc/nsswitch.conf; then sed -i~ -e '/^group:/ s/$$/ ldap/' /etc/nsswitch.conf; fi" \
		sudo:"if ! grep ^shadow:.*ldap$$ /etc/nsswitch.conf; then sed -i~ -e '/^shadow:/ s/$$/ ldap/' /etc/nsswitch.conf; fi" \
		sudo:"systemctl restart nscd" \
		sudo:"systemctl restart nslcd"
	touch "$@"

# TODO: check ldap in /etc/nsswitch.conf
