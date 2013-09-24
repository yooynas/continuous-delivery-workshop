#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='<fill in role here>'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

echo "<please echo what you are doing!>..."
if [ -z "<test if this piece of code really needs to be run again, see idempotence>" ];then
  <do what ever you want. remember: you are root. the force is with you.>
fi

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"