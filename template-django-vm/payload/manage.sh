#!/bin/bash
export DJANGO_SETTINGS_MODULE="math_siteconf.settings"
export VIRTUAL_ENV="${HOME}/.virtualenvs/mathapp"
export PATH="$VIRTUAL_ENV/bin:$PATH"
unset PYTHON_HOME
django-admin.py "$@"
