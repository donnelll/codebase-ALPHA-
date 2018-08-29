#!/usr/bin/python

# Tucker - 082912
# Check registration, currnet config channel and install yum-downloadonly pkg on possible clients
# Updated on Oct 31 2013 for RHEL 5.10 use


import xmlrpclib
import sys



class rhnsat_lib(object):


    # Clients should be listening to one of our standard RHEL 5 base channels
    # before attempting to get the yum-downloadonly package
    #rhel5_base_ids = [105,247,543,323,423,363,623,266,483]
    def __init__(self):
        self.rhel5_base_ids = [105,247,543,323,423,363,623,266,483,1265]
        self.verbose = False

    # Since we are loop through files we need to ensure host objects are fresh each loop through
    def resetVariables(self):
        self.ghid = ''
        self.bcid = ''
        self.bcname = ''
        self.bid = ''
        self.cclist = ''
        self.gsbc_result = ''
        self.gscc_result = ''
        self.status = ''




    # Connect to RHNSAT method
    def connect(self, url, user, pswd):
        try:
            self.client = xmlrpclib.Server(url, verbose=0)
            self.session = self.client.auth.login(user, pswd)
            self.registered = {}
        except:
            print "Error - Unable to connect to RHN server"
            sys.exit()

    # Open ingest file and grab hostname
    def parseFile(self, filepath):
        try:
            self.host_list = []
            file = open(filepath)
            lines = file.readlines()
            for line in lines:
                host = line.rstrip()
                self.host_list.append(host)

        except IOError:
            if self.verbose == True:
                print "Error - Unable to read file"

    # Check if the host is registered by
    def regCheck(self, host, registered):
        count = 0
        if host in registered.values():
           count  += 1
        if count == 1:
            #print 'Okay'
            return 1
        if count == 0:
            #print 'Error - system not registered'
            return 0
        if count > 1:
            #print 'Error - multiple systems registered with name %s' % (host)
            return 2

    # Set the base channel
    def setBaseChannel(self, serverID, bid):
        try:
            self.serverID = serverID
            self.bid = bid
            results = self.client.system.setBaseChannel(self.session, self.serverID, self.bid)

            if results == 1: # Success setting base channel
                self.setbc = 'Yes'
            else:
                self.setbc = 'No'

        except xmlrpclib.Fault:
            if self.verbose == True:
                print "Error problem changing base channel"

    # Set the child channel
    def setChildChannel(self, serverID, cid):
        try:
            self.cid = cid
            ccresults = self.client.system.setChildChannels(self.session, self.serverID, self.cid)
            if ccresults == 1: # Success setting base channel
                self.setcc = 'Yes'
            else:
                self.setcc = 'No'
        except xmlrpclib.Fault:
            if self.verbose == True:
                print "Error problem changing child channel"


    # Get the numerical hostid for the system
    def gethostID(self, hostname):

        try:
            self.hostname = hostname
            self.ghid = self.client.system.getId(self.session, self.hostname)


            if len(self.ghid) > 1:
                #print "%S - Error! Duplicate hostnams found for host " % (self.hostname)
                self.status = "Error - Multiple systems found"
                self.bcid = ''

            elif len(self.ghid) == 0:
                self.status = "Error - Not Registered!"
                self.bcid = ''
            else:
                self.ghid = self.ghid[0]['id']
        except IndexError:
            if self.verbose == True:
                print "%s - Error! Unable to find ID for system " % (self.hostname)



    # Get the ID and name of the channel the client is registered with
    def subscribedBaseChannel(self, serverID, host):
        try:
            self.gsbc_result = self.client.system.getSubscribedBaseChannel(self.session,serverID)

            if self.gsbc_result['name']:
                self.bcid  = self.gsbc_result['id']
                self.bcname = self.gsbc_result['name']
                self.status = "Registered"


                if self.bcid in self.rhel5_base_ids:  # Check if the client is RHEL 5 based
                    self.rhel5_client = True
                else:
                    self.rhel5_client = False
            else:
                self.bcid  = ''
                self.bcname = ''


        except:
            if self.verbose == True:
                print "%s - Error! Problem getting Subscribed Base Channel" % (host)


    # Get the ID and name of the child channel the client is registered to
    def getSubscribedChildChannel(self, serverID, host):
        try:
            self.gscc_result = self.client.system.listSubscribedChildChannels(self.session,serverID)

            if self.gscc_result:
              self.cclist = []
              for row in self.gscc_result:
                 self.cclist.append(row['name'])
            else:
                self.cclist = ''
        except:
            if self.verbose == True:
                print "%s - Error! Problem getting subscribed child channel" % (host)


    # Build an array of registered clients
    def buildRegisteredList(self):

        try:
            print "Building a list of registered systems"
            syslist = self.client.system.listActiveSystems(self.session)

            for host in syslist:
                self.registered[host['id']]= host['name']
            return self.registered
        except:
            if self.verbose == True:
                print "Problem building registered systems list"

    # Push the RHEL 5 yum-download-only package
    def installYumDwnld(self, serverID, pid):
        try:
            self.serverID = serverID
            self.pid = pid
            install_results = self.client.system.schedulePackageInstall(self.session, self.serverID, self.pid, xmlrpclib.DateTime(0))

            if install_results == 1:
                self.yum_installed = 'Yes'
            else:
                self.yum_installed = 'No'
        except:
            if self.verbose == True:
                print "Problem install yum download only"

    def registrationDataCollect(self, host):
        self.hostname = host
        self.gethostID(host) # Get the serverID for this host


        if self.ghid:  # If we get a host id back then we are good
            self.subscribedBaseChannel(self.ghid, host) # Get base channel for this serverID

            if self.bcid and self.status == "Registered": # If we get base channel id back then proceed and get child channels
                self.getSubscribedChildChannel(self.ghid, host)


    def printRegistrationData(self):
        try:

            if self.status == "Registered" and self.rhel5_client == True:
                print "%-20s  Status:  %s" % (self.hostname, self.status)
                print "   Base Channel: " + self.bcname
                for channel in self.cclist:
                    print "    \- Child Channel: " + channel

            elif self.status == "Registered" and self.rhel5_client == False:
                print "%-20s  Status: Registered \033[0;31m Error! - Not a RHEL 5 System\033[0m" % (self.hostname)
                print "   Base Channel: " + self.bcname
                for channel in self.cclist:
                    print "    \- Child Channel: " + channel

            else:
                print "%-20s  Status: \033[0;31m%s\033[0m" % (self.hostname, self.status)
        except:
            if self.verbose == True:
                print "Problem with printing registration data"

