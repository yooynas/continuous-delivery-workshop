#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='selenium'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

apt-get install -y xvfb

if [ ! -f /etc/init.d/headless-selenium ];then
  echo "Installing Selenium..."
  install -o root -g root -m 755 -d /etc/headless-selenium
  install -o root -g root -m 755 -d /var/log/selenium
  install -o root -g root -m 755 -d /usr/lib/headless-selenium
  install -o root -g root -m 755 -d /usr/lib/headless-selenium/profiles
  install -o root -g root -m 755 -d /usr/lib/headless-selenium/profiles/firefox
  install -o root -g root -m 755 -d /usr/lib/headless-selenium/profiles/firefox/selenium
  install -o root -g root -m 755 $CONF_PHOME/recipes/$RECIPE/headless-selenium /etc/init.d
  install -o root -g root -m 644 $CONF_PHOME/recipes/$RECIPE/selenium.conf /etc/headless-selenium

  SELENIUM_JAR="selenium-server-standalone-2.31.0.jar"

  install -o ${CONF_DUSER} -g ${CONF_DGROUP} -m 755 -d /home/$CONF_DUSER/Downloads
  [ ! -z "$(file /home/$CONF_DUSER/Downloads/${SELENIUM_JAR} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${SELENIUM_JAR}
  
  if [ ! -f /home/$CONF_DUSER/Downloads/${SELENIUM_JAR} ];then
    echo "Downloading Selenium-Server jar from ${PROVISIONING_SERVER_URI}/${SELENIUM_JAR}..."
    wget -q -O /home/$CONF_DUSER/Downloads/${SELENIUM_JAR} ${PROVISIONING_SERVER_URI}/${SELENIUM_JAR} > /dev/null
    chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${SELENIUM_JAR}
  fi
  install -o root -g root -m 644 /home/$CONF_DUSER/Downloads/${SELENIUM_JAR} /usr/lib/headless-selenium
fi

/etc/init.d/headless-selenium stop || true
/etc/init.d/headless-selenium start

update-rc.d headless-selenium defaults

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
