
payload/payload/django-settings.json: ../cluster.conf ../_scripts/syslog_host_choices.py
	../_scripts/syslog_host_choices.py $< $@

django-settings-fix.evt: payload/django-settings.json 
	touch "$@"
