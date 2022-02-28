#!/bin/bash
#cd /ivre-share
export  PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

filename="/data/assets.txt"
scan_log="/var/log/ivre.log"
scan_root_dir="/ivre-share/scans/$(date +%Y%m%d)"

if ! [ -d $scan_root_dir ]; then
  mkdir -p $scan_root_dir
fi

yes | IVRE_CONF=$conf_file ivre ipinfo --init 
yes | IVRE_CONF=$conf_file ivre scancli --init
yes | IVRE_CONF=$conf_file ivre view --init
yes | IVRE_CONF=$conf_file ivre flowcli --init
yes | IVRE_CONF=$conf_file ivre runscansagentdb --init
for line in $(cat $filename)
do
  if [[ "$line" =~ ^#.* ]]; then 
    continue; 
  fi
  str=$line
  OLD_IFS="$IFS"
  IFS=";"
  arr=($str)
  IFS="$OLD_IFS"
  n='([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])'
  m='[1-9]|[1-2][0-9]|3[0-2]'
  p='([0-9]|[1-9][0-9]|[1-9][0-9]{2}|[1-9][0-9]{3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])'
  if [[ ${arr[0]} =~ ^$n(\.$n){3}$ ]]; then
    arr[0]="${arr[0]}/32"
  fi
  port=$(echo ${arr[1]} | sed 's/ //g')
  if [[ -z $port ]]; then
    port="1-65535"
  fi
  if [[ ${arr[0]} =~ ^$n(\.$n){3}/$m$ ]]; then
    tmpstr=$(echo ${arr[0]} | sed 's/\//_/g')
    scan_dir=$scan_root_dir/$tmpstr
    if ! [ -d $scan_dir ] ; then
      mkdir $scan_dir
    fi
    conf_file="$scan_dir/ivre.conf"
    /bin/cp -f /data/ivre.conf $conf_file
    sed -i "s/\[\"ports\"\] = \".*\"/\[\"ports\"\] = \"$port\"/g" $conf_file
    cd $scan_dir
    IVRE_CONF=$conf_file ivre runscans --nmap-template ivre-scan --network ${arr[0]} --output=XMLFork && IVRE_CONF=$conf_file ivre scan2db -s ${arr[2]:-default} -c ${arr[3]:-default} -r $scan_dir/scans/*/up && IVRE_CONF=$conf_file ivre db2view nmap 
  elif [[ -f ${arr[0]} ]]; then
    tmpstr=$(basename ${arr[0]})
    scan_dir=$scan_root_dir/$tmpstr
    if ! [ -d $scan_dir ] ; then
      mkdir $scan_dir
    fi
    conf_file="$scan_dir/ivre.conf"
    /bin/cp -f /data/ivre.conf $conf_file
    sed -i "s/\[\"ports\"\] = \".*\"/\[\"ports\"\] = \"$port\"/g" $conf_file
    cd $scan_dir
    /bin/cp -f ${arr[0]} $scan_dir
    IVRE_CONF=$conf_file ivre runscans --nmap-template ivre-scan -f $tmpstr --output=XMLFork && IVRE_CONF=$conf_file ivre scan2db -s ${arr[2]:-default} -c ${arr[3]:-default} -r $scan_dir/scans/*/up && IVRE_CONF=$conf_file ivre db2view nmap 
  fi
done

touch /ivre-share/.done
