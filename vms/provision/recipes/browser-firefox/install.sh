#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='browser-firefox'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

if [ -z "$(grep iceweasel-release /etc/apt/sources.list)" ];then
  echo "deb http://mozilla.debian.net/ wheezy-backports iceweasel-release" >> /etc/apt/sources.list
  apt-get update
  apt-get --yes --quiet --allow-unauthenticated install pkg-mozilla-archive-keyring
  apt-get update
fi

apt-get --yes install -t wheezy-backports iceweasel

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
