#!/bin/bash

# CD Workshop
# TeilnehmerVM
# aka cdvm
# Shell Provisioner
#
set -e

PROVISIONING_TARGET_NAME=$1
if [ -z "${PROVISIONING_TARGET_NAME}" ];then
  echo "ERROR: ARG1 muss Targetmaschinen Namen enthalten: cdvm oder testvm!"
  exit 1
fi

echo "###################################################"
echo "# CREATING VM OF TYPE ${PROVISIONING_TARGET_NAME}"
echo "###################################################"

# environment configuration
PROVISIONING_GIT_URI=https://github.com/pingworks/continuous-delivery-workshop.git
PROVISIONING_SERVER_FQDN=www.pingworks.de
PROVISIONING_SERVER_URI=http://${PROVISIONING_SERVER_FQDN}/vagrant

# Base Configuration
CONF_DUSER=vagrant
CONF_DGROUP=vagrant
CONF_DHOME=/home/$CONF_DUSER
CONF_PHOME=/srv/deploy/vms/provision

case "${PROVISIONING_TARGET_NAME}" in  
cdvm)
  
  RECIPES="base-all base-cdvm runtime-java jenkins selenium apache2-php pingworks-dash repo x-desktop desktop-files browser-firefox"

  DEPLOY_ENV_DEPLOY_HOST="cdvm"
  DEPLOY_ENV_DOMAIN_SUFFIX=".cd-workshop.local"
  DEPLOY_ENV_STAGE="dev"
  DEPLOY_ENV_IP="192.168.56.100"
  ;;

testvm)
  RECIPES="base-all base-testvm runtime-java"

  DEPLOY_ENV_DEPLOY_HOST="testvm"
  DEPLOY_ENV_DOMAIN_SUFFIX=".testenv01.cd-workshop.local"
  DEPLOY_ENV_STAGE="dev"
  DEPLOY_ENV_IP="192.168.56.101"
  ;;  
esac

DEPLOY_ENV_VMHOST_IP="192.168.56.1"
DEPLOY_ENV_DEPLOY_HOST_FQDN=${DEPLOY_ENV_DEPLOY_HOST}${DEPLOY_ENV_DOMAIN_SUFFIX}

if [ -z "${RECIPES}" ];then
  echo "ERROR: no recipes defined."
  exit 1
fi

if [ -f ${CONF_DHOME}/dont_provision_again ];then
  echo "Diese VM ist vollstaendig provisioniert."
  echo "(${CONF_DHOME}/dont_provision_again loeschen fuer erneutes provisionieren)"
  exit 0
fi

echo "###################################################"
echo "# BEGIN Provisioning"
echo "###################################################"
echo "FQDN: $DEPLOY_ENV_DEPLOY_HOST_FQDN"
echo "IP: $DEPLOY_ENV_IP"
echo "RECIPES: $RECIPES"
echo "###################################################"


echo "Checking Network Connectivity..."
[ -z "$(grep ${DEPLOY_ENV_DEPLOY_HOST_FQDN} /etc/hosts)" ] && echo "${DEPLOY_ENV_IP}  ${DEPLOY_ENV_DEPLOY_HOST_FQDN}" >> /etc/hosts

set +e

PINGTEST=$(ping -c1 $PROVISIONING_SERVER_FQDN)
if [ $? -ne 0 ];then
  echo "ERROR: Host $PROVISIONING_SERVER_FQDN ist nicht erreichbar. Bitte ueberpruefen und mit \"vagrant provision\" erneut starten!"
  exit 1
fi

PINGTEST=$(ping -c1 ${DEPLOY_ENV_DEPLOY_HOST_FQDN})
if [ $? -ne 0 ];then
  echo "ERROR: Kann keine Netzwerkverbindung zu \"mir selbst\" herstellen: ${DEPLOY_ENV_DEPLOY_HOST_FQDN} ist nicht erreichbar."
  exit 1
fi
set -e

echo "###################################################"
echo "# SETTING deploy env configuration"
echo "###################################################"

DEPLOY_ENV_CONFDIR=/srv/deploy-env-config
echo "Setting up DEPLOY_ENV_CONFDIR=${DEPLOY_ENV_CONFDIR}..."
[ ! -d ${DEPLOY_ENV_CONFDIR} ] && mkdir -p ${DEPLOY_ENV_CONFDIR} 

echo "${DEPLOY_ENV_DOMAIN_SUFFIX}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_DOMAIN_SUFFIX   
echo "${DEPLOY_ENV_STAGE}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_STAGE   
echo "${DEPLOY_ENV_IP}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_IP   
echo "${DEPLOY_ENV_VMHOST_IP}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_VMHOST_IP
echo "${DEPLOY_ENV_DEPLOY_HOST}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_DEPLOY_HOST
echo "${DEPLOY_ENV_DEPLOY_HOST_FQDN}" > ${DEPLOY_ENV_CONFDIR}/DEPLOY_ENV_DEPLOY_HOST_FQDN
echo "${PROVISIONING_SERVER_URI}" > ${DEPLOY_ENV_CONFDIR}/PROVISIONING_SERVER_URI
echo "${PROVISIONING_GIT_URI}" > ${DEPLOY_ENV_CONFDIR}/PROVISIONING_GIT_URI
echo "${CONF_DUSER}" > ${DEPLOY_ENV_CONFDIR}/CONF_DUSER
echo "${CONF_DGROUP}" > ${DEPLOY_ENV_CONFDIR}/CONF_DGROUP
echo "${CONF_DHOME}" > ${DEPLOY_ENV_CONFDIR}/CONF_DHOME
echo "${CONF_PHOME}" > ${DEPLOY_ENV_CONFDIR}/CONF_PHOME

HOME_VAGRANT_FOLDERS="apps workspace workspace/continuous-delivery-workshop"
for F in $HOME_VAGRANT_FOLDERS;do
  if [ ! -d "${CONF_DHOME}/$F" ];then 
    mkdir -v -p ${CONF_DHOME}/$F
    chown ${CONF_DUSER}.${CONF_DGROUP} ${CONF_DHOME}/$F
  fi
done

SYMLINKS="${CONF_DHOME}/workspace/continuous-delivery-workshop:/srv/deploy"
for SL in $SYMLINKS;do
  SLSRC=$(echo $SL | awk -F ':' '{ print $1; }')
  SLTRG=$(echo $SL | awk -F ':' '{ print $2; }')
  if [ ! -L $SLTRG ];then
    echo "Erstelle Symlink $SLTRG..."
    ln -s $SLSRC $SLTRG
  fi
done

# -----------------------------------------
[ ! -d /data/git ] && mkdir /data/git
chown jenkins.${CONF_DGROUP} /data/git
chmod 2775 /data/git

cd /data/git
if [ ! -d continuous-delivery-workshop/.git ];then
  echo "Cloning continuous-delivery-workshop (1)..."
  apt-get update
  apt-get install -y git
  sudo -u vagrant git clone ${PROVISIONING_GIT_URI} continuous-delivery-workshop
else
  echo "Updating /data/git/continuous-delivery-workshop ..."
  cd continuous-delivery-workshop
  sudo -u vagrant git pull
fi

cd ${CONF_DHOME}/workspace

if [ ! -d continuous-delivery-workshop/.git ];then
  echo "Cloning continuous-delivery-workshop from /data/git (2)..."
  sudo -u vagrant git clone /data/git/continuous-delivery-workshop continuous-delivery-workshop
else
  echo "Updating ${CONF_DHOME}/workspace/continuous-delivery-workshop from /data/git..."
  cd continuous-delivery-workshop
  sudo -u vagrant git pull
fi

if [ ! -d /srv/deploy/vms/provision ];then
  echo "ERROR: Provisioning dir /srv/deploy/vms/provision not found!"
  exit 1
fi

echo "###################################################"
echo "# Now provisioning..."
echo "###################################################"
for RECIPE in $RECIPES;do
  echo "recipe: $RECIPE"
  bash /srv/deploy/vms/provision/recipes/$RECIPE/install.sh
  if [ $? -ne 0 ];then
     echo "ERROR: Provisioning with recipe $RECIPE fehlgeschlagen!"
     exit 1
  fi
done

echo "###################################################"
echo "# END Provisioning"
echo "###################################################"
touch ${CONF_DHOME}/dont_provision_again
chown ${CONF_DUSER}.${CONF_DGROUP} ${CONF_DHOME}/dont_provision_again
