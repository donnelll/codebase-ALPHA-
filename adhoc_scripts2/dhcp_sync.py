#!/usr/bin/python

# Tom Tucker
# Feb 13 2010
# Purpose: Sync DHCP and TFTP connect to slaves and to restart DHCP process

import os
import re
import ping
import socket

# Remove finger and nscd below 

# Variables
dhcpd_restart = 0
restart_results = []
unreachable_systems = []
process = 'isc-dhcp-server'
Linux_DHCP_Servers = ['usg-admin3902']
#Linux_DHCP_Servers = ['usg-admin3902','usg-admin2001','usg-admin4001']
#Linux_DHCP_Servers = ['usg-admin3902']
Solaris_DHCP_Servers = ['tribeca','beetle','rogue','jetta']
#Solaris_DHCP_Servers = ['rogue','jetta']
pid_path = '/var/run/dhcpd.pid'
#rdist_content = ['/var/isc-dhcp/conf/dhcpd.conf','/var/isc-dhcp/conf/net/*.conf','/tftpboot/']

def LinuxProcCheck():
	print "* Checking Status of Linux DHCP Processes"
	for lds in Linux_DHCP_Servers: 
		if lds not in unreachable_systems:
			check_command = "ssh root@%s \"service dhcpd status\"" % (lds)
			output = os.popen(check_command)
			for line in output.readlines():
				line = re.sub('\n','', line)
				results = "%s\t\t%s" % (lds, line)
				restart_results.append(results)

def LinuxRestart(system):
	restart_command = "ssh root@%s \"service dhcpd restart\"" % (system)
	os.system(restart_command)
	print "* DHCP Process restarted on %s" % (system)

def SolarisProcCheck():
	print "* Checking Status of Solaris DHCP Processes"
	for sds in Solaris_DHCP_Servers:
		if sds not in unreachable_systems:
			check_command = "ssh root@%s 'svcs %s'" % (sds, process)
			output = os.popen(check_command)
			for line in output.readlines():
				line = re.sub('\n','', line)
				proc_line = re.search("..*svc:",line)
				if proc_line:
					temp_line = re.split('\s+', line)
					status = temp_line[0]
					results =  "%s\t%s" % (sds, status)
					restart_results.append(results)



def SolarisRestart(system):
	restart_command = "ssh root@%s 'svcadm restart %s'" % (system, process)
	os.system(restart_command)
	print "* DHCP Process restarted on %s" % (system)
		
def whichRestart(system):
	if system in Solaris_DHCP_Servers:
		SolarisRestart(system)
	if system in Linux_DHCP_Servers:
		LinuxRestart(system)
	
def connectivityCheck():
	print "* Confirming connectivity to the DHCP servers"
	for system in Solaris_DHCP_Servers:
		try:
    			delay = ping.do_one(system, timeout=2)
			if delay:
				print "- %s is reachable. Proceeding..." % (system)
				Sync(system)
			else:
				print "- %s is unreachable. Skipping!" % (system)
				unreachable_systems.append(system)
				results =  "%s\t\tUnreachable" % (system)
				restart_results.append(results)
				
				
		except socket.error, e:
    			print "Ping Error:", e

	for system in Linux_DHCP_Servers: 
		try:
    			delay = ping.do_one(system, timeout=2)
			if delay:
				print "- %s is reachable. Proceeding..." % (system)
				Sync(system)
			else:
				print "- %s is unreachable. Skipping!" % (system)
				unreachable_systems.append(system)
				results =  "%s\t\tUnreachable" % (system)
				restart_results.append(results)
		except socket.error, e:
    			print "Ping Error:", e
			

	# We are done, check and print the results
	SolarisProcCheck()
	LinuxProcCheck()
	print "--------------------------------------"
	for line in restart_results:
		print line 
	
		
	
	
# Sync content to remote servers
def Sync(system):
	print "Syncing content with %s" % (system)
	sync_one = "/usr/bin/rsync -avz  /tftpboot/ -e ssh root@%s:/tftpboot" % (system)
	sync_two = "/usr/bin/rsync -avz  /var/isc-dhcp/conf/dhcpd.conf -e ssh root@%s:/var/isc-dhcp/conf/dhcpd.conf" % (system)
	sync_three = "/usr/bin/rsync -avz  /var/isc-dhcp/conf/net/*.conf -e ssh root@%s:/var/isc-dhcp/conf/net" % (system)
	os.system(sync_one)
	os.system(sync_two)
	os.system(sync_three)
	whichRestart(system)
	


# Lets make sure this pid exists and its alive
def checkProc(pid):
	if os.path.exists("/proc/"+pid):
		print "* Process %s is running" % (pid)
		global dhcpd_restart 
		if dhcpd_restart == 0:
			print "* Lets restart the DHCPD process again to make sure our configs are ok."
			dhcpd_restart = 1
			os.system("service dhcpd restart")
			pidfileCheck()
		else:
			connectivityCheck()
	else:
		print "* DHCPD Process %s is not running.\n" % (pid)
		print "This might be caused of an error in one of the DHCP files"
		print "or this process just isn't running. Please try the following.\n"
		print "Start the process - \"service dhcpd start\""
		print "Watch for errors  - \"tail -f /var/log/messages | grep dhcpd\""

# Read contents of the pid file
def checkPID():
	file = open(pid_path)
	line = file.readline()
	line = re.sub('\n','', line)
	pid = line
	print "* Process ID in file is - %s" % (pid)
	checkProc(pid)
	

# Do we have a pid file?
def pidfileCheck():
	if os.path.isfile(pid_path):
        	print "* Pid file found - %s" % (pid_path)
		checkPID()
	else:
		print "DHCPD Process not running.  Please run \"service dhcpd start\""

if __name__ == "__main__":  
	pidfileCheck()
