include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



imagemagick_policy.evt: payload/policy.xml | fabadmin.evt       ## Update ImageMagick policy.xml
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		deploy.putconf:"$<,/etc/ImageMagick-6/,use_sudo=True,mode=0644" \
		sudo:"chown root:root /etc/ImageMagick-6/policy.xml"
	touch "$@"

