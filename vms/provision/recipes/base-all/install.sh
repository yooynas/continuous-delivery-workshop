#!/bin/bash
#
# please notice: all provisioning scripts have to be idempotent
#

. /srv/deploy/vms/provision/common.sh

set -e 
RECIPE='base-all'

echo "# -------------------------------------------------"
echo "# BEGIN Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"

apt-get update

echo "Installing basic sytem tools..."
apt-get --yes install less htop vim git curl unzip ncdu iftop aptitude file

echo
echo "Installing .vimrc for root and $CONF_DUSER..."
cp $CONF_PHOME/recipes/$RECIPE/dot_vimrc /root/.vimrc
cp $CONF_PHOME/recipes/$RECIPE/dot_vimrc /home/$CONF_DUSER/.vimrc
chown root.root /root/.vimrc
chown $CONF_DUSER.$CONF_DGROUP /home/$CONF_DUSER/.vimrc

echo
echo "Installing .bashrc for root..."
cp $CONF_PHOME/recipes/$RECIPE/root_dot_bashrc /root/.bashrc
chown root.root /root/.bashrc

if [ -z "$(grep 'EDITOR=vi' /home/$CONF_DUSER/.bashrc)" ];then
    echo
    echo "Setting up editor vi as default for user $CONF_DUSER..."
    echo "export EDITOR=vi" >> /home/$CONF_DUSER/.bashrc
fi
if [ -z "$(grep 'EDITOR=vi' /root/.bashrc)" ];then
	echo
    echo "Setting up editor vi as default for user root..."
	echo "export EDITOR=vi" >> /root/.bashrc
fi

adduser vagrant adm

if [ -z "$(cat /etc/ssh/sshd_config | grep UseDNS )" ];then
    echo "UseDNS no" >> /etc/ssh/sshd_config
fi

echo "# -------------------------------------------------"
echo "# END Provisioning RECIPE $RECIPE"
echo "# -------------------------------------------------"