#!/bin/bash
shopt -s expand_aliases
source ~/.bash_aliases

# This is a simple script that will run through list of systems and set the SP (Service
# processer) to use static IP instead of DHCP utilizing a set of local ipmitool commands that
# should be available.  There will be another script written that will utilize racadm
# remote commands.

FILE="hosts.spchange"
NETMASK="255.255.252.0"
GATEWAY="10.229.80.1"

for OUTPUT in $(for i in `cat $FILE`; 
do 
	getent hosts sp-$i |awk '{ print $1 }'
done)

do
        echo "Processing $OUTPUT" 
done
