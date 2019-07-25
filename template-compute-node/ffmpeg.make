include ../_make/lib/check_defined.mk
# Required standard variables:
$(call check_defined, VIRTUAL_ENV MGMT_FABFILE FQDN)



ffmepg_install.evt: | fabadmin.evt       ## Update latest ffmpeg
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u fabadmin -H $(FQDN) \
		sudo:"if [[ \$$(lsb_release -cs) \=\= "xenial" ]]; then add-apt-repository -uy ppa:jonathonf/ffmpeg-3; DEBIAN_FRONTEND\=noninteractive apt install -yq libav-tools; fi" \
		sudo:"DEBIAN_FRONTEND\=noninteractive apt install -yq ffmpeg x264 x265" 
	touch "$@"

