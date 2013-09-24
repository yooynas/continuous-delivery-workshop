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

echo "Installing Jenkins..."
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
apt-get update > /dev/null 2>&1
apt-get --yes install jenkins

/etc/init.d/jenkins stop

JENKINS_PLUGINS=plugins.tar.gz
echo "Downloading Jenkins Plugins from ${PROVISIONING_SERVER_URI}/${JENKINS_PLUGINS}..."
wget -q -O - ${PROVISIONING_SERVER_URI}/${JENKINS_PLUGINS} \
  | tar xz -C /var/lib/jenkins
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
