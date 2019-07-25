
include ../_make/django-user.make ../_make/localpypi.make ../_make/virtualenv.make


django-db.evt: 
    # Use $(DEPLOY_ADMIN) rather than fabadmin b/c of user=postgres
	ping -qc 1 $(DBFQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u $(DEPLOY_ADMIN) -H $(DBFQDN) \
		sudo:"psql rsyslog -c 'GRANT SELECT ON ALL TABLES IN SCHEMA public TO logapp',user=postgres" 
	touch "$@"


virtualenv.post.evt: | django.db.evt localpypi.evt virtualenv.evt django-user.evt nfs_client.evt
	ping -qc 1 $(FQDN)
	. $(VIRTUAL_ENV)/bin/activate && \
	fab -f $(MGMT_FABFILE) -u django -H $(FQDN) \
		django.migrate:"virtualenv_path=~/.virtualenvs/$(NAME),manage_cmd=manage.py" \
		django.collectstatic:"virtualenv_path=~/.virtualenvs/$(NAME),manage_cmd=manage.py"
	touch "$@"


django-setup.evt: localpypi.evt virtualenv.prep.evt virtualenv.evt virtualenv.post.evt | django-user.evt