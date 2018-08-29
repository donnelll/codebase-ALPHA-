#!/bin/bash
#
# ADSRV common Script for Kickstart
#
# PL  2-11-08
#
# Source function library.
. /etc/rc.d/init.d/functions

yum -y install httpd
yum -y install gcc gcc-c++
yum -y install glibc glibc-common glibc-devel
yum -y install libaio libaio-devel
yum -y install libgcc
yum -y install make
yum -y install libstdc++
yum -y install compat-libstdc++-33.i686
yum -y install libstdc++.i686
yum -y install expat-devel.i386
yum -y install compat*

yum -y update

groupadd -g 60008 dclick
useradd -u 60013 -g dclick -d /data/home/dclick -s /bin/ksh -c "Dclick Account" dclick
mkdir -p /data/home/dclick
chown -R dclick:dclick /data/home/dclick

echo "-------------------   Starting Redline Common -------------"

echo "SYSTEM INFORMATION" >> /etc/motd
echo "HOST:        $HOSTNAME" >> /etc/motd
echo "FUNCTION:    ADSRV" >> /etc/motd
echo "DEPARTMENT:  ADSRV" >> /etc/motd
echo "DESCRIPTION: ADSRV" >> /etc/motd
echo "" >> /etc/motd
echo "If any of the above information is incorrect, or displayed as unknown please contact the Unix Team - atusg@autotrader.com" >> /etc/motd
echo "" >> /etc/motd


echo "-------------------   END Redline Common -------------"

