#!/bin/bash
mkdir -p /usr/local/software/jdk
cd /usr/local/software/jdk
wget 10.226.138.247/software/jdk/jdk-1.6.0_13-fcs.i586.rpm
chmod 755 *
rpm -ivh jdk*.rpm
yum install rsyslog -y
chkconfig syslog off
chkconfig rsyslog on
service syslog stop
service rsyslog start
curl -Sks 10.102.8.232/data/dell/om/install/rhel5/om72install.sh | /bin/bash
lvextend -l +100%FREE /dev/mapper/VolGroup00-LogVol02
resize4fs -p /dev/mapper/VolGroup00-LogVol02
chmod 1777 /data
cd /etc
wget 10.226.138.247/software/fast/passwd
wget 10.226.138.247/software/fast/group
mv -f /etc/passwd.1 /etc/passwd
mv -f /etc/group.1 /etc/group
mkdir -p /usr/local/software/cfengine
cd /usr/local/software/cfengine
wget 10.226.138.247/software/cfengine/rhel564/cfengine-3.1.2-1.RHEL5_x86_64.rpm
chmod 755 *
rpm -ivh *.rpm
mkdir -p /data/home/fast/.ssh
wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/authorized_keys
wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/id_dsa
wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/id_dsa.pub
wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/identity
wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/identity.pub
#wget -P /data/home/fast/.ssh 10.226.138.247/software/fast/ssh/known_hosts
wget -P /data/home/fast/ 10.226.138.247/software/fast/ssh/.bashrc
wget -P /data/home/fast/ 10.226.138.247/software/fast/ssh/.bash_profile
chown -R fast:fast /data/home/fast;chmod 700 /data/home/fast;chmod 700 /data/home/fast/.ssh;chmod 644 /data/home/fast/.bash*;chmod 644 /data/home/fast/.ssh/*
chmod 600 /data/home/fast/.ssh/authorized_keys;chmod 600 /data/home/fast/.ssh/id_dsa;chmod 600 /data/home/fast/.ssh/identity
mkdir -p /data/home/sismon/.ssh
wget -P /data/home/sismon/.ssh 10.226.138.247/software/fast/sismon/ssh/authorized_keys
chmod 755 /data/home/sismon/;chmod 400 /data/home/sismon/.ssh/*
chown -R sismon:sismon /data/home/sismon
yum install compat-libstdc* screen rrdtool httpd --nogpgcheck -y
mkdir -p /usr/local/software/fast
wget -P /usr/local/software/fast 10.226.138.247/software/fast/oracle-config-1.1-7.el5sat.noarch.rpm
wget -P /usr/local/software/fast 10.226.138.247/software/fast/oracle-instantclient-basic-10.2.0-47.el5sat.i386.rpm
wget -P /usr/local/software/fast 10.226.138.247/software/fast/oracle-instantclient-sqlplus-10.2.0-47.el5sat.i386.rpm
chmod 755 /usr/local/software/fast/*
rpm -ivh --force --nodeps /usr/local/software/fast/*.rpm

