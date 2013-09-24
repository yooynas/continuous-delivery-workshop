#!/bin/bash

DEPLOY_ENV_CONFDIR=/srv/deploy-env-config
for DEPLOY_ENV_CONFFILE in $(ls -1 $DEPLOY_ENV_CONFDIR); do
  TMPVALUE=$(cat $DEPLOY_ENV_CONFDIR/$DEPLOY_ENV_CONFFILE)
  #echo "DEBUG: Reading $DEPLOY_ENV_CONFFILE: $TMPVALUE"
  declare $DEPLOY_ENV_CONFFILE=$TMPVALUE
done

function substituteDeployEnvVars() {
  local FILEPATH=$1
  local TMPPATTERN=""
  local DEPLOY_ENV_CONFFILE=""
  
  if [ ! -f $FILEPATH ];then
    echo "ERROR: substituteDeployEnvVars() File $FILEPATH not found!"
    exit 1
  fi
  #echo "DEBUG: DEPLOY_ENV_CONFDIR=${DEPLOY_ENV_CONFDIR}"
  for DEPLOY_ENV_CONFFILE in $(ls -1 ${DEPLOY_ENV_CONFDIR});do
    TMPPATTERN="__"${DEPLOY_ENV_CONFFILE}"__"
    #echo "DEBUG: TMPPATTERN=$TMPPATTERN"
    #echo "DEBUG: substituteDeployEnvVars() Substitution PATTERN=$TMPPATTERN VALUE=${!DEPLOY_ENV_CONFFILE}"
    sed -i -e "s;$TMPPATTERN;${!DEPLOY_ENV_CONFFILE};g" $FILEPATH
    if [ $? -ne 0 ];then
      echo "ERROR: Failed sed -i s/$TMPPATTERN/${!DEPLOY_ENV_CONFFILE}/g on $FILEPATH"
      exit 1
    fi
  done
  if [ ! -z "$(grep __DEPLOY_ENV_ $FILEPATH)" ];then
    echo "ERROR: substituteDeployEnvVars() File $FILEPATH has unsubstituted __DEPLOY_ENV_*__ Variables!"
    exit 1
  fi      
}

function cpAndSubstDeployEnvVars() {
  local SOURCEFILE=$1
  local DESTPATH=$2
  local OWNER=$3
  local PERMS=$4
  
  local DESTFILE=""
  local FILENAME=$(basename $SOURCEFILE)
  if [ ! -d $DESTPATH ];then
    if [ -d "$(dirname $DESTPATH)" ];then
      DESTFILE=$DESTPATH
    else
      echo "ERROR: cpAndSubstDeployEnvVars() Destination path $DESTPATH not found!"
      exit 1
    fi
  else
    DESTFILE=$DESTPATH/$FILENAME
  fi
  
  [ -z "$OWNER" ] && OWNER="azddepl.azddepl"
  [ -z "$PERMS" ] && PERMS="0644"
  
      
  if [ ! -f "$SOURCEFILE" ];then
    echo "ERROR: cpAndSubstDeployEnvVars() Sourcefile $SOURCEFILE not found!"
    exit 1
  fi
  if [ ! -d "$(dirname $DESTFILE)" ];then
    echo "ERROR: cpAndSubstDeployEnvVars() Destination dir $(dirname $DESTFILE) not found!"
    exit 1
  fi
  cp -ax "$SOURCEFILE" "$DESTPATH"
  if [ $? -ne 0 ];then
    echo "ERROR: Failed to cp $SOURCEFILE $DESTPATH."
    exit 1
  fi
  substituteDeployEnvVars $DESTFILE
  chown $OWNER $DESTFILE
  if [ $? -ne 0 ];then
    echo "ERROR: Failed to change ownership $OWNER of $DESTFILE."
    exit 1
  fi
  chmod $PERMS $DESTFILE
  if [ $? -ne 0 ];then
    echo "ERROR: Failed to set permissions $PERMS on $DESTFILE."
    exit 1
  fi
  
}