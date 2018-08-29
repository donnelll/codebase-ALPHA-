#!/bin/bash
# Adapted from Patricks RHEL4 postinstall, it's dirty but should work -sm
# Source function library.
. /etc/rc.d/init.d/functions


#
# Install Additional Software
#
up2date -u
up2date ntp subversion subversion-devel subversion-perl osad zsh net-snmp sysstat
up2date OpenIPMI OpenIPMI-devel OpenIPMI-libs OpenIPMI-tools


#
# Modify Swap Size to equal Physical Memory
#
MEMORY=`free | grep Mem | awk '{print $2}'`
echo "Growing Swap to a Total size of $MEMORY"
lvextend -L${MEMORY}K /dev/VolGroup00/LogVol01
mkswap /dev/VolGroup00/LogVol01


#
# Resize Data
#
echo "Growing Data  to fill all remaining space"
PE=`vgdisplay /dev/VolGroup00 | grep "Free  PE" | awk '{print $5}'`
lvextend -l+${PE} /dev/VolGroup00/LogVol02
resize2fs /dev/VolGroup00/LogVol02


#
# Deploy Configuration Files
#
echo "Deploying Configuration Files"
rhncfg-client get && success $"GET $i" || failure $"GET $i"


#
# Disable unwanted services
#
for i in avahi-daemon bluetooth gpm pcscd auditd hidd kudzu cups pcmcia iptables isdn cpuspeed
do
        chkconfig --level 0123456 $i off
done

#
# Turn on services
# 

chkconfig --level 2345 ntpd on
chkconfig --level 2345 osad on
chkconfig --level 2345 snmpd on
chkconfig --level 2345 snmptrapd on
chkconfig --level 2345 ipmi on



echo "SYSTEM INFORMATION" >> /etc/motd
echo "HOST:        $HOSTNAME" >> /etc/motd
echo "FUNCTION:    MB" >> /etc/motd
echo "DEPARTMENT:  MB" >> /etc/motd
echo "DESCRIPTION: Magic Bus" >> /etc/motd
echo "" >> /etc/motd
echo "If any of the above information is incorrect, or displayed as unknown please contact the Unix Team - atusg@autotrader.com" >> /etc/motd
echo "" >> /etc/motd

#
# Misc Tasks 
#
rm /etc/logrotate.d/mysqld

mkdir -p /packages

rm -f /etc/cron.daily/00-logwatch

cp /etc/rc.local /etc/rc.local.orig
echo "/bin/mount -a" >> /etc/rc.local

# Set the hostname to be the short one
NAME=`hostname --short`
[ -n "$NAME" ] && hostname $NAME


# -- Grub Config Section
# Edit some grub properties
# Ditch the pretty graphical booting.
perl -p -i -e 's/rhgb//' /boot/grub/grub.conf

# Take out the pretty splash image.  HP ilo's without the license puke on this
perl -p -i -e 's/^splashimage/#splashimage/' /boot/grub/grub.conf
# -- END Grub Config Section

# -- Up2date Config Section
perl -p -i -e 's/useGPG=1/useGPG=0/' /etc/sysconfig/rhn/up2date
perl -npe 's/pkgSkipList=kernel\*/pkgSkipList=/' -i /etc/sysconfig/rhn/up2date


usermod -c root@`hostname -s`.autotrader.com root

ln -s /bin/sh /usr/bin/sh
ln -s /bin/bash /usr/bin/bash
ln -s /bin/ksh /usr/bin/ksh
ln -s /bin/tcsh /usr/bin/tcsh
ln -s /bin/csh /usr/bin/csh
ln -s /bin/ksh /usr/bin/ksh93
ln -s /bin/false /usr/bin/false
ln -s /bin/zsh /usr/bin/zsh


# -- Satellite Config Section --
# We need this directory and file so the Satellite server will automatically send the updates
mkdir -p /etc/sysconfig/rhn/allowed-actions/configfiles
touch /etc/sysconfig/rhn/allowed-actions/configfiles/all
# -- END Satellite Config Section --

# Set hostname to be SHORT name
perl -p -i -e 's/.autotrader.com//' /etc/sysconfig/network

# Pull IP Address and Gateway
IPADDR=`ifconfig eth0 | grep "inet addr" | awk '{print $2}'|awk -F: '{print $2}'`
GW=`ip route | grep default | awk '{print $3}'`

# Create the new file
echo "DEVICE=eth0" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo "ONBOOT=yes" >>  /etc/sysconfig/network-scripts/ifcfg-eth0
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "IPADDR=$IPADDR" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-eth0
echo "GATEWAY=$GW" >> /etc/sysconfig/network-scripts/ifcfg-eth0



#
# Magic Bus Unique
#
echo "-------------------   Starting Magic Bus Common -------------"
wget http://rhnsat.autotrader.com/scripts/mb.tar
tar -xvf mb.tar
cd mb
rpm -ivh j*rpm

# -- MB Config Section --
mkdir /data/
chmod 777 /data
groupadd -g 4034 atcmb
adduser -u 4034 -g 4034 -d /data/atcmb -m -r -s /bin/bash -c 'ATCMB User' atcmb
chmod 777 /data
chown -R atcmb /data/atcmb

cd /
mkdir /data/data2
mkdir /data/data3
mkdir /data/data4
ln -sf /data/data2 /data2
ln -sf /data/data3 /data3
ln -sf /data/data4 /data4

# NetBackup
#
echo "-------------------   Install Veritas Netbackup -------------"
cd /root
wget http://rhnsat.autotrader.com/scripts/NetBackup.tar.gz
tar -zxvf /root/NetBackup.tar.gz -C /
rm /root/NetBackup.tar.gz
perl -p -i -e "s#mb207#`hostname`#" /usr/openv/netbackup/bp.conf
echo "vnetd           13724/tcp                       # Veritas Network Utility" >> /etc/services
echo "vnetd           13724/udp                       # Veritas Network Utility" >> /etc/services
echo "bpcd            13782/tcp                       # VERITAS NetBackup" >> /etc/services
echo "bpcd            13782/udp                       # VERITAS NetBackup" >> /etc/services
