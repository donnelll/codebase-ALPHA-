#!/bin/bash
 
OMREPORT=/opt/dell/srvadmin/sbin/omreport
OMCONFIG=/opt/dell/srvadmin/sbin/omconfig
 
echo "Running sanity checks..."
# Check that this is a R720 hadoop datanode
/usr/sbin/dmidecode -t1 |egrep -q 'Product Name:.*R720'
if [ "$?" != "0" ]
then
    echo "This script should only be run on a dell r720!"
    exit 1
fi
echo $HOSTNAME |egrep -q '^phd40'
if [ "$?" != "0" ]
then
    echo "This script should only be run on hadoop data nodes!"
    exit 1
fi
 
# Check that OMSA is operational
$OMREPORT storage pdisk controller=0 &>/dev/null
if [ "$?" != "0" ]
then
    /opt/dell/srvadmin/sbin/srvadmin-services.sh restart
    $OMREPORT storage pdisk controller=0 &>/dev/null
    if [ "$?" != "0" ]
    then
        echo "There is an issue with OMSA."
        echo "Please correct and re-run."
        exit 1
    fi
fi
 
# Prompt for info and match to data
echo
echo
echo -n "Enter the physical disk tray number you replaced: " ; read DISK_NUMBER
case $DISK_NUMBER in
    0) DISK_NAME=HDATA1; DISK_MOUNT_POINT=/hdata/1 ;;
    1) DISK_NAME=HDATA2; DISK_MOUNT_POINT=/hdata/2 ;;
    2) DISK_NAME=HDATA3; DISK_MOUNT_POINT=/hdata/3 ;;
    3) DISK_NAME=HDATA4; DISK_MOUNT_POINT=/hdata/4 ;;
    4) DISK_NAME=HDATA5; DISK_MOUNT_POINT=/hdata/5 ;;
    5) DISK_NAME=HDATA6; DISK_MOUNT_POINT=/hdata/6 ;;
    6) DISK_NAME=HDATA7; DISK_MOUNT_POINT=/hdata/7 ;;
    7) DISK_NAME=HDATA8; DISK_MOUNT_POINT=/hdata/8 ;;
    8) DISK_NAME=HDATA9; DISK_MOUNT_POINT=/hdata/9 ;;
    9) DISK_NAME=HDATA10; DISK_MOUNT_POINT=/hdata/10 ;;
    10) DISK_NAME=HDATA11; DISK_MOUNT_POINT=/hdata/11 ;;
    11) DISK_NAME=HDATA12; DISK_MOUNT_POINT=/hdata/12 ;;
    *) echo "Incorrect disk tray number." ;;
esac
 
echo
echo "PHYSICAL DISK TRAY: $DISK_NUMBER"
echo "HDATA VOLUME:       $DISK_NAME"
echo "MOUNT POINT:        $DISK_MOUNT_POINT"
echo
echo "This info will be used to unmount and format the disk"
echo -n "Please *carefully* verify the information above is correct.  Proceed? [YES/NO]: "
read ANSWER
if [ "$ANSWER" != "YES" ]
then
    echo 'You must enter "YES" to proceed.'
    exit 1
fi
 
if [ "$1" != "--force" ]
then
    ls $DISK_MOUNT_POINT &>/dev/null
    if [ "$?" = "0" ]
    then
        echo "The disk you specified was checked for IO errors and none were found."
        echo "Please investigate and re-run if necessary."
        echo "If the mountpoint has already been unmounted, rerun this script with the "--force" option."
        exit 1
    fi
fi
# Lazy umount the failed disk
umount -l $DISK_MOUNT_POINT &>/dev/null
# Clear the foreign state and preserved cache and re-create vdisk
echo "Clearing foreign config and preserved cache..."
$OMCONFIG storage controller action=clearforeignconfig controller=0 &>/dev/null
$OMCONFIG storage controller action=discardpreservedcache controller=0 force=disabled &>/dev/null
 
echo "Creating vdisk from physical disk \"0:1:${DISK_NUMBER}\" with name \"${DISK_NAME}\" ..."
$OMCONFIG storage controller action=createvdisk controller=0 raid=r0 size=max pdisk=0:1:${DISK_NUMBER} writepolicy=wb readpolicy=ara name=${DISK_NAME}
sleep 10
if [ "$?" != "0" ]
then
    echo "The vdisk creation failed for physical disk \"0:1:${DISK_NUMBER}\" and name \"${DISK_NAME}\""
    echo "Manual intervention is needed."
fi
 
# Find the "sd" device name
echo "Finding the the /dev/sdX name for the vdisk that was created..."
for VDISK_NUMBER in 1 2 3 4 5 6 7 8 9 10 11 12
do
    $OMREPORT storage vdisk controller=0 vdisk=${VDISK_NUMBER} |grep '^Name' |awk '{print $3}' |grep -q $DISK_NAME
    if [ "$?" = "0" ]
    then
        DISK_SD_NAME=`$OMREPORT storage vdisk controller=0 vdisk=${VDISK_NUMBER} |grep '^Device Name' |awk '{print $4}'`
        break
    fi
done
 
if [ "$VDISK_NUMBER" = "" ]
then
    echo "Unable to find VDISK with the name \"$DISK_NAME\"."
    echo "Manual intervention is needed."
    exit 1
fi
# Format and mount the disk
echo "Formatting $DISK_SD_NAME ..."
echo y | mkfs.ext4 $DISK_SD_NAME
tune2fs -m 0 $DISK_SD_NAME
 
echo "Mounting $DISK_MOUNT_POINT ..."
mount $DISK_SD_NAME $DISK_MOUNT_POINT
if [ "$?" != "0" ]
then
    echo "Disk mount failed"
    exit 1
fi
 
echo "Disk mounted successfully!"
df -h $DISK_MOUNT_POINT
echo
echo "Reboot the system to reorder the disk"
