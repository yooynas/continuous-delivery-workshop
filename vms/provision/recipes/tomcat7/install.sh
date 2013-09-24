#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='tomcat7'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

echo "Installing tomcat..."
apt-get install -y tomcat7

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"