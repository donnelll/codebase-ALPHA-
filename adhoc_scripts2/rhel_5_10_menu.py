#!/usr/bin/python

from rhel_5_10_patch_lib import *
import optparse
import getpass

def usage():
    print "Your options are:"
    print "                -c    Check RHNSAT registration of clients"
    print "                -f    File path containing the list of clients"
    print "                -l    Single linux host to manage"
    print "                -p    Password to RHNSAT (Default: http://usg-rhn4901"
    print "                -r    RHNSAT server URL"
    print "                -s    Set 5.10 Channel"
    print "                -u    Username for RHNSAT"
    print "                -v    Versbose output"
    print "                -y    Yum install yum-download-only package"
    sys.exit()



def OptionsCheck(parser):
    opts, args = parser.parse_args()
    options_count = 0

    # Check what was defined on the cmd line  if not display help banner
    if opts.username:
        options_count += 1
    if opts.setchannel:
        options_count += 1
    if opts.check_reg:
        options_count += 1
    if opts.yum:
        options_count += 1

    # We are assuming we should have a minimum of two command line options defined
    # 1 - username
    # 2 - task to run
    # if not display help banner
    if options_count < 2:
        usage()


    # If the password is not defined on the command line then ask for it.
    if opts.username and not opts.password:
        opts.password = getpass.getpass('RHNSAT Password for %s: ' % (opts.username))

    # If username and password variables are not set then exit
    # we can't proceed without them
    if not opts.username or not opts.password:
        print "Please identify login credentials"
        sys.exit()


    # ****************************************
    # Connect to RHNSAT
    # ****************************************
    if opts.username and opts.password:
        x = rhnsat_lib()
        x.connect("https://usg-rhn4901/rpc/api", opts.username, opts.password)

    # *******************
    # Clients to manage
    # - what are we processing? a file or single host?
    # ******************

    # File with no host defined
    if opts.file and not opts.host:
        x.parseFile(opts.file)
        x.process_type = 'file'

    elif opts.host and not opts.file:
        x.process_type = 'host'
    elif opts.file and opts.host:
        print "Error - Please specify a file containing a list of hosts or either a single host"
        sys.exit()


    # ******************
    # Check registration
    # *******************

    if opts.check_reg == True:

        print " *************** REGISTRATION CHECK ************************"
        if x.process_type == 'file':
            for host in x.host_list:
               x.resetVariables()
               x.registrationDataCollect(host)
               x.printRegistrationData()
        if x.process_type == 'host':
            x.registrationDataCollect(opts.host)
            x.printRegistrationData()


    # ********************
    # Set 5.10 Channels
    # ********************
    if opts.setchannel == True:
        print " *************** SET 5.10 CHANNELs ************************"
        if x.process_type == 'file':
            for host in x.host_list:
                x.rhel5_client = False # zero it out
                x.resetVariables()
                x.registrationDataCollect(host)

                if x.rhel5_client == True:
                    x.setBaseChannel(x.ghid,1265)
                    x.setChildChannel(x.ghid,[1270,1268,1269,1266,1267])
                    print "%-20s   Base Channel Set: %s   Child Channel Set: %s" % (host, x.setbc, x.setcc)
                else:
                    print "%-20s   Base Channel Set: \033[0;31m%s\033[0m   Child Channel Set: \033[0;31m%s\033[0m" % (host, "Error", "Error")

        if x.process_type == 'host':
            x.rhel5_client = False
            x.registrationDataCollect(opts.host)
            if x.rhel5_client == True:
                x.setBaseChannel(x.ghid,1265)
                x.setChildChannel(x.ghid,[1270,1268,1269,1266,1267])
                print "%-20s   Base Channel Set: %s   Child Channel Set: %s" % (opts.host, x.setbc, x.setcc)
            else:
                print "%-20s   Base Channel Set: \033[0;31m%s\033[0m   Child Channel Set: \033[0;31m%s\033[0m" % (opts.host, "Error", "Error")



    # *********************************
    # Install yum-download_only Package
    # *********************************

    if opts.yum == True:
        print " *************** INSTALLING yum-downloadonly Package ************************"
        if x.process_type == 'file':
            for host in x.host_list:
                x.rhel5_client = False
                x.resetVariables()
                x.registrationDataCollect(host)
                if x.rhel5_client == True:
                    x.installYumDwnld(x.ghid, [38828])
                    print "%-20s Yum Installed: %s" % (host, x.yum_installed)
                else:
                    print "%-20s Yum Installed: \033[0;31mError! Not a RHEL 5 System\033[0m" % (host)



        if x.process_type == 'host':
            x.rhel5_client = False
            x.registrationDataCollect(opts.host)
            if x.rhel5_client == True:
                x.installYumDwnld(x.ghid, [15503])
                print "%-20s Yum Installed: %s" % (opts.host, x.yum_installed)
            else:
                print "%-20s Yum Installed: \033[0;31mError! Not a RHEL 5 System\033[0m" % (opts.host)





    if options_count == 0:
        usage()


def main():
    parser = optparse.OptionParser()
    parser.add_option('-c', '--check_registration', dest="check_reg", action="store_true", help="Check if systems are registered")
    parser.add_option('-f', '--file', dest='file', action="store", help="file containing list of hosts")
    parser.add_option('-l', '--linux_host', dest='host', action="store", help="linux host to manage")
    parser.add_option('-p', '--password', dest='password', action="store", help="RHNSAT password")
    parser.add_option('-s', '--setchannel', action="store_true", dest="setchannel", help="Set base and child channels to 5.8")
    parser.add_option('-u', '--username', dest='username', action="store", help="RHNSAT username")
    parser.add_option('-v', '--verbose', dest="verbose", action="store_true", help="verbose output")
    parser.add_option('-y', '--yum_dwnld_pkg', dest="yum", action="store_true", help="Install yum-downloadonly package")
    OptionsCheck(parser)


if __name__ == '__main__':
    main()


