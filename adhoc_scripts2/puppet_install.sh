#!/bin/bash

##################################
# Puppet Wrapper Install Script
# T.K. Tucker
# Autotrader.com
# May 29th 2015
#
# curl -k http://10.102.41.32:8888/scripts/puppet_install.sh | bash
#################################

#command: ./puppet_install.sh [env]


# ------------------------------------------------------
# Check if Puppet is already installed.  If so, exit.
# ------------------------------------------------------
if [ -a '/etc/puppet' ]
  then
	echo "Traces of Puppet found....exiting."
	exit 1
fi

# ------------------------------------------------------
# Check command line arguments.  
# Q - Did we receive the Puppet master that will support this host?
# Q - Does this host provided match three possible Puppet masters?
# ------------------------------------------------------

if [ $# -ne 1 ];
  then
    echo "Exiting!  Please pass the Puppet Master environment to support this client."
    echo "./depoy_puppet.sh [qpupmstr4901|spupmstr9901|pupmstr4901]"
    echo "dev/qa = qpupmstr4901, pp = spupmstr9901, prod = pupmstr4901"
    exit 1
  else
    pupmstr_array=(qpupmstr4901 spupmstr9901 pupmstr4901)
    if [[ " ${pupmstr_array[@]}" =~ "$1" ]]; then
      puppetmaster=$1
    else
      echo "Exiting!  Please pass the Puppet Master environment to support this client."
      echo "./depoy_puppet.sh [qpupmstr4901|spupmstr9901|pupmstr4901]"
      echo "dev/qa = qpupmstr4901, pp = spupmstr9901, prod = pupmstr4901"
      exit 1
    fi

fi


# ------------------------------------------------------
# Check OS type and architecture
# ------------------------------------------------------

OSARCH=`uname -a | awk '{print $1}'`
ARCH=`uname -m`
os_version=`cat /etc/redhat-release | sed 's/\./ /g' | awk '{print $7}'`
PPNET=`ifconfig -a | grep 10.225 | wc -l`



# ------------------------------------------------------
# Check if this system is on a PreProd network
# and if so set variables
# ------------------------------------------------------
if [[ "$PPNET" > 0 ]]
   then
      echo "This is a PP system"

      echo "Setting proxy server variables"
      export http_proxy="http://10.225.130.242:3128"
      export proxy="http://10.225.130.242:3128"

      export myrpm='rpm -ivh --httpproxy 10.225.130.242 --httpport 3128'
      #export environment='preprod'


else
      echo "Setting proxy server variables"
      export http_proxy="http://10.102.71.242:3128"
      export proxy="http://10.102.71.242:3128"

      export myrpm='rpm -ivh --httpproxy 10.102.71.242 --httpport 3128'
      #export environment='production'

fi

# ------------------------------------------------------
# Set Puppet environment based on Puppet Master defined
# ------------------------------------------------------

if [ "$puppetmaster" == "qpupmstr4901" ];
 then
   environment='development'
elif [ "$puppetmaster" == "spupmstr9901" ];
 then
   environment='preprod'
else
   environment='production'
fi


# ------------------------------------------------------
# We don't do Solaris
# ------------------------------------------------------

if [[ "$ARCH" = "i86pc" && "$OSARCH" = "SunOS" ]]
   then 

	echo "Solaris x86 architecture detected...exiting"
	exit 1
fi

if [[  "$OSARCH" = "Linux" ]]
   then 
	if [ "$os_version" = 5 ]
          then
                yumrpm='http://yum.puppetlabs.com/puppetlabs-release-el-5.noarch.rpm'

	elif [ "$os_version" = 6 ]
          then
                yumrpm='http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm'

	elif [ "$os_version" = 7 ]
          then
                yumrpm='http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm'
	else
		echo "Unable to determine RHEL version!"
		exit 1
	fi

        # Install YUM Repo
        echo "Installing yum repo"
        `$myrpm $yumrpm`

        # Install Puppet
        echo "Installing Puppet"
        `$myrpm $yumrpm`
        yum install -y --nogpgcheck puppet


        # Create custom puppet.conf
        echo "Creating customized /etc/puppet/puppet.conf"

echo "[main]
# The Puppet log directory.
# The default value is '$vardir/log'.
logdir = /var/log/puppet

# Where Puppet PID files are kept.
# The default value is '$vardir/run'.
rundir = /var/run/puppet

# Where SSL certificates are kept.
# The default value is '$confdir/ssl'.
ssldir = $vardir/ssl
server = $puppetmaster.autotrader.com

[agent]
# The file in which puppetd stores a list of the classes
# associated with the retrieved configuratiion.  Can be loaded in
# the separate ``puppet`` executable using the ``--loadclasses``
# option.
# The default value is '$confdir/classes.txt'.
classfile = $vardir/classes.txt

# Where puppetd caches the local configuration.  An
# extension indicating the cache format is added automatically.
# The default value is '$confdir/localconfig'.
localconfig = $vardir/localconfig
pluginsync = true
environment = $environment" > /etc/puppet/puppet.conf

	# Disable CFEngine
	echo "Disabling and stopping CFEngine"
	chkconfig cfexecd off
	service cfexecd stop

	# Enable Puppet on Startup
	echo "Enable Puppet on Startup"
	chkconfig puppet on

	# Starting Puppet 
	echo "Starting Puppet"
	service puppet start
fi
