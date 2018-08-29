#!/bin/bash

cmd="ssh -t $1 sudo /usr/sbin/lshw"


`echo $cmd` >/usr/local/nagios/share/$2.txt
exit 0
