#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/config.sh
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='ide-eclipse'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
[ ! -d /home/$CONF_DUSER/Downloads ] && mkdir /home/$CONF_DUSER/Downloads 
if [ ! -f /home/$CONF_DUSER/Downloads/eclipse-jee.tar.gz ];then
wget -q -O /home/$CONF_DUSER/Downloads/eclipse-jee.tar.gz ${PROVISIONING_SERVER_URI}/eclipse-jee.tar.gz > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/eclipse-jee.tar.gz
fi

if [ ! -d /home/$CONF_DUSER/apps/eclipse ];then
  cd /home/$CONF_DUSER/apps/
  tar xfz /home/$CONF_DUSER/Downloads/eclipse-jee.tar.gz
  chown -R $CONF_DUSER.users /home/$CONF_DUSER/apps/eclipse
fi

ECLIPSE_LAUNCHES_DIR=/home/$CONF_DUSER/workspace/.metadata/.plugins/org.eclipse.debug.core/.launches

[ ! -d $ECLIPSE_LAUNCHES_DIR ] && mkdir -p $ECLIPSE_LAUNCHES_DIR

rsync -avx $CONF_PHOME/recipes/$RECIPE/launches/ ${ECLIPSE_LAUNCHES_DIR}/

apt-get install -y xauth libgtk2.0-0 libcanberra-gtk-module libxtst6

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
