#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

# include global configuration

. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='jenkins'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

echo "Installing maven..."
apt-get --yes install maven

echo "Installing Jenkins..."
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
apt-get update > /dev/null 2>&1
apt-get --yes install jenkins

/etc/init.d/jenkins stop

rsync -a /home/vagrant/.ssh/ /var/lib/jenkins/.ssh/
chown -R jenkins.nogroup /var/lib/jenkins/.ssh/

JENKINS_PLUGINS=plugins.tar.gz

install -o ${CONF_DUSER} -g ${CONF_DGROUP} -m 755 -d /home/$CONF_DUSER/Downloads

[ ! -z "$(file /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS} | grep empty)" ] && rm /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS}
  
if [ ! -f /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS} ];then
  echo "Downloading Jenkins Plugins from ${PROVISIONING_SERVER_URI}/${JENKINS_PLUGINS}..."
  wget -q -O /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS} ${PROVISIONING_SERVER_URI}/${JENKINS_PLUGINS} > /dev/null
  chown $CONF_DUSER.users /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS}
fi

tar xz -C /var/lib/jenkins -f /home/$CONF_DUSER/Downloads/${JENKINS_PLUGINS}
chown -R jenkins.nogroup /var/lib/jenkins/plugins

install -o jenkins -g nogroup -m 644 $CONF_PHOME/recipes/$RECIPE/config.xml /var/lib/jenkins/
install -o jenkins -g nogroup -m 644 $CONF_PHOME/recipes/$RECIPE/hudson.tasks.Maven.xml /var/lib/jenkins/
install -o jenkins -g nogroup -m 755 -d /var/lib/jenkins/workspace

for i in 1 2 3; do
  install -o jenkins -g nogroup -m 755 -d /var/lib/jenkins/jobs${i}
  rsync -a $CONF_PHOME/recipes/$RECIPE/jobs${i}/ /var/lib/jenkins/jobs${i}/
  chown -R jenkins.nogroup /var/lib/jenkins/jobs${i}/
done

if [ ! -d /var/lib/jenkins/jobs -a ! -L /var/lib/jenkins/jobs ]; then
  ln -s /var/lib/jenkins/jobs1 /var/lib/jenkins/jobs
fi

[ -d /data/repo ] || mkdir -p /data/repo
chown jenkins.nogroup /data/repo    

/etc/init.d/jenkins start

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"
