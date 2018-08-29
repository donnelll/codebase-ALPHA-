df -h | grep /hdata | awk '{print $6}' | xargs -l umount -l
/bin/sleep 2
HDATA1_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sda$'`
HDATA2_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdb$'`
HDATA3_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdc$'`
HDATA4_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdd$'`
HDATA5_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sde$'`
HDATA6_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdf$'`
HDATA7_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdg$'`
HDATA8_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdh$'`
HDATA9_DISK=`ls -l  /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdi$'`
HDATA10_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdj$'`
HDATA11_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdk$'`
HDATA12_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdl$'`
HDATA13_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdm$'`
HDATA14_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdn$'`
HDATA15_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdo$'`
HDATA16_DISK=`ls -l /dev/disk/by-id/ | grep -i "scsi-SATA*" | awk -F/ '{print $NF}' | sed 's:^:/dev/:g' | sort |grep '/dev/sdp$'`

e2label $HDATA1_DISK hdata1
e2label $HDATA2_DISK hdata2
e2label $HDATA3_DISK hdata3
e2label $HDATA4_DISK hdata4
e2label $HDATA5_DISK hdata5
e2label $HDATA6_DISK hdata6
e2label $HDATA7_DISK hdata7
e2label $HDATA8_DISK hdata8
e2label $HDATA9_DISK hdata9
e2label $HDATA10_DISK hdata10
e2label $HDATA11_DISK hdata11
e2label $HDATA12_DISK hdata12
e2label $HDATA13_DISK hdata13
e2label $HDATA14_DISK hdata14
e2label $HDATA15_DISK hdata15
e2label $HDATA16_DISK hdata16
/bin/sleep 3
mount -a 
/bin/sleep 3
df -hTP | grep /hdata | sort
