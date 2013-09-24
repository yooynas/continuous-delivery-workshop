#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='base-cdvm'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

echo "Installing vm specific /etc/hosts file..."

echo "$CONF_PHOME/recipes/$RECIPE/etc_hosts"
cpAndSubstDeployEnvVars $CONF_PHOME/recipes/$RECIPE/etc_hosts /etc/hosts root.root 644

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
