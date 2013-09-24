#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='runtime-java'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

JAVA_DEB="oracle-j2sdk1.7_1.7.0+update40_amd64.deb"

[ ! -d /home/$CONF_DUSER/Downloads ] && mkdir /home/$CONF_DUSER/Downloads
[ ! -z "$(file /home/$CONF_DUSER/Downloads/${JAVA_DEB} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${JAVA_DEB}
  
if [ ! -f /home/$CONF_DUSER/Downloads/${JAVA_DEB} ];then
  echo "Downloading Java Runtime Environment from ${PROVISIONING_SERVER_URI}/${JAVA_DEB}..."
  wget -q -O /home/$CONF_DUSER/Downloads/${JAVA_DEB} ${PROVISIONING_SERVER_URI}/${JAVA_DEB} > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${JAVA_DEB}
fi

if [ -z "$(java -version 2>&1 | grep 1.7.0_40)" ];then
  echo "Installing Java Runtime..."
  dpkg -i /home/$CONF_DUSER/Downloads/${JAVA_DEB}
fi

update-alternatives --set java /usr/lib/jvm/j2sdk1.7-oracle/jre/bin/java

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"