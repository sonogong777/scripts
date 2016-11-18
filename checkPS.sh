#!/bin/bash
##########################################################################
# Copyright 2014 by Cisco Systems, Inc.
# All rights reserved.
# Cisco Systems, Inc. makes no representations
# or warranties, either express or implied, by or with respect to
# anything in this source code, and shall not be liable for any
# implied warranties of merchantability or fitness for a
# particular purpose or for any indirect, special or consequential
# damage. This source code is unsupported unless otherwise
# explicitly stated.
# This software is the confidential and proprietary information
# of Cisco Systems. ("Confidential Information").
##########################################################################

VERSION=0.1.0
SUBJECT=PScheckForFlapping
VAULTS=(
  'ccdn-ps-wcdc-01'
  'ccdn-ps-vn-01'
  'ccdn-ps-mt-01'
)
LOGFILE=$0.out
COUNT=200
DAMAGED=findDamaged_1108_10.sh

rm -rf $LOGFILE

if [ $# -ne 0 ]; then
  if [[ $1 =~ ^[-+]?[0-9]+$ ]];then
     echo "Using count $1"
     COUNT=$1;
  else
     echo "Usage:  $0 <THRESHOLD COUNT>";
     echo "Issuing this command without parameters will use default COUNT of $COUNT.";
     exit 1;
  fi
else
  echo "Using default count of $COUNT";
fi

checkVault() {

ssh -T $1 <<'EOSSH'
  today=`date|awk '{print $2" "$3}'`
  yestarday=`date --date="1 day ago"|awk '{print $2" "$3}'`
  grep -e "$today" -e "$yestarday" /var/log/messages*|grep "Reachable Vault"|wc -l
EOSSH

}

getVaultData() {

ssh -T $1 <<'EOSSH'
  hostname
  date
  today=`date|awk '{print $2" "$3}'`
  yestarday=`date --date="1 day ago"|awk '{print $2" "$3}'`
  #echo $today
  #echo $yestarday
  echo "count of Reachable Vault messages"
  grep -e "$today" -e "$yestarday" /var/log/messages*|grep "Reachable Vault"|wc -l
  echo "top 5 vaults showing restart"
  grep -e "$today" -e "$yestarday" /var/log/messages*|grep "Reachable Vault"|awk '{print $8}'|sort |uniq -c|sort -nr|head -5
EOSSH

}


echo "Checking following vaults for flapping"
echo ${VAULTS[@]}
NOTOK=0

for i in "${VAULTS[@]}"
do
 #ping test
 /bin/ping -c 2 $i > /dev/null
 if [ $? -eq 0 ]; then
    if [[ $(checkVault $i) -gt $COUNT ]];then
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
        echo "Possible issue detected $i"
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
        getVaultData $i
        NOTOK=1
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
    fi
  else
   echo "In Vault $i is not reachable..."
   echo "Moving on.."
  fi
done > $LOGFILE

if [ $NOTOK != 0 ];then
   echo "Possible issue detected, check logfile $LOGFILE, EXIT STATUS 1"
   exit 1
fi

echo "No issues detected, proceed with findDamaged script, EXIT STATUS 0"
echo "running $DAMAGED"
./$DAMAGED
