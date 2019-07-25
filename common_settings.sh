
DOMAIN="example.com"

DEPLOY_ADMIN='$(CLUSTER_USER)'
MGMT_FABFILE="../../mgmt-fab/fabfile"
VIRTUAL_ENV="~/.virtualenvs/fab"

MAIL_RELAY="mail.${DOMAIN}"
ROOT_EMAIL="root@${DOMAIN}"

PYPI="https://pypi.example.com/localpypi/"