#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

. /srv/deploy/vms/provision/config.sh
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='base-cdvm'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

TESTHOSTNAME="${DEPLOY_ENV_DEPLOY_HOST_FQDN}"
echo "Checking /etc/hosts..."
if [ -z "$(cat /etc/hosts | grep ${TESTHOSTNAME})" ];then
    echo "Installing vm specific /etc/hosts file..."
    cpAndSubstDeployEnvVars $CONF_PHOME/recipes/$RECIPE/etc_hosts /etc/hosts root.root 644
fi

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
