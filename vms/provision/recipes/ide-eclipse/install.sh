#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration

. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='ide-eclipse'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

ECLIPSE_BUNDLE="eclipse-full-bundle.tar"

install -o ${CONF_DUSER} -g ${CONF_DGROUP} -m 755 -d /home/$CONF_DUSER/Downloads

[ ! -z "$(file /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE}
  
if [ ! -f /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE} ];then
  echo "Downloading Monster 615MB eclipse Bundle from ${PROVISIONING_SERVER_URI}/${ECLIPSE_BUNDLE}..."
  wget -N -q -O /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE} ${PROVISIONING_SERVER_URI}/${ECLIPSE_BUNDLE} > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE}
fi

if [ ! -d /home/$CONF_DUSER/apps/eclipse ];then
  cd /home/$CONF_DUSER
  sudo -u $CONF_DUSER tar xf /home/$CONF_DUSER/Downloads/${ECLIPSE_BUNDLE}
fi

ECLIPSE_LAUNCHES_DIR=/home/$CONF_DUSER/workspace/.metadata/.plugins/org.eclipse.debug.core/.launches

[ ! -d $ECLIPSE_LAUNCHES_DIR ] && mkdir -p $ECLIPSE_LAUNCHES_DIR

#rsync -avx $CONF_PHOME/recipes/$RECIPE/launches/ ${ECLIPSE_LAUNCHES_DIR}/

apt-get install -y xauth libgtk2.0-0 libcanberra-gtk-module libxtst6

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
