#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration
. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='pingworks-dash'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

DASH_FRONTEND_DEB="dash-frontend_1+git.fbb93bdf-145_all.deb"
DASH_BACKEND_DEB="dash-backend_1+git.fbb93bdf-145_all.deb"
DASH_REPO_URI="https://dash.pingworks.net/repo/master/1.fbb93bdf.145/artifacts/"

[ ! -d /home/$CONF_DUSER/Downloads ] && mkdir /home/$CONF_DUSER/Downloads
[ ! -z "$(file /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB}
[ ! -z "$(file /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB}
    
if [ ! -f /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB} ];then
  echo "Downloading Java Runtime Environment from ${DASH_REPO_URI}/${DASH_FRONTEND_DEB}..."
  wget -q -O /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB} ${DASH_REPO_URI}/${DASH_FRONTEND_DEB} > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB}
fi

if [ ! -f /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB} ];then
  echo "Downloading Java Runtime Environment from ${DASH_REPO_URI}/${DASH_BACKEND_DEB}..."
  wget -q -O /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB} ${DASH_REPO_URI}/${DASH_BACKEND_DEB} > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB}
fi

apt-get install -y zendframework

if [ -z "$(dpkg --get-selections | grep dash-frontend | grep install)" ];then
  dpkg -i /home/$CONF_DUSER/Downloads/${DASH_FRONTEND_DEB}
fi

if [ -z "$(dpkg --get-selections | grep dash-backend | grep install)" ];then
  dpkg -i /home/$CONF_DUSER/Downloads/${DASH_BACKEND_DEB}
fi

if [ ! -f /etc/apache2/sites-available/dash ];then
    cat << EOF > /etc/apache2/sites-available/dash
<VirtualHost *:80>
ServerName dash

DocumentRoot /opt/dash/public

SetEnv APPLICATION_ENV "production"

<Directory /opt/dash/public>
AllowOverride All
Order allow,deny
Allow from all
</Directory>

</VirtualHost>
EOF
fi
a2enmod rewrite
a2dissite 000-default
a2ensite dash

/etc/init.d/apache2 restart


echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"