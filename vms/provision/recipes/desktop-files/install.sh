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

echo "Installing Jenkins Job Scripts.."
install -o vagrant -g vagrant -m 755 -d /home/vagrant/Desktop
install -o vagrant -g vagrant -m 755 $CONF_PHOME/recipes/$RECIPE/Pipeline1.sh /home/vagrant/Desktop
install -o vagrant -g vagrant -m 755 $CONF_PHOME/recipes/$RECIPE/Pipeline2.sh /home/vagrant/Desktop
install -o vagrant -g vagrant -m 755 $CONF_PHOME/recipes/$RECIPE/Pipeline3.sh /home/vagrant/Desktop

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"