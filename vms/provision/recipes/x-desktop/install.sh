#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='x-desktop'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

if [ -z "$(grep mate-desktop /etc/apt/sources.list)" ];then
  echo "deb http://repo.mate-desktop.org/debian wheezy main" >> /etc/apt/sources.list
  apt-get update
  apt-get --yes --quiet --allow-unauthenticated install mate-archive-keyring
  apt-get update
fi

# this installs the base packages
apt-get install --yes --allow-unauthenticated xorg slim mate-desktop-environment

/etc/init.d/slim start

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"