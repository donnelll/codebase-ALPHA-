#!/bin/bash
echo "Red Hat Satellite Server Client bootstrap script v4.0"

# This file was autogenerated. Minor manual editing of this script (and
# possibly the client-config-overrides.txt file) may be necessary to complete
# the bootstrap setup. Once customized, the bootstrap script can be triggered
# in one of two ways (the first is preferred):
#
#   (1) centrally, from the Red Hat Satellite Server via ssh (i.e., from the
#       Red Hat Satellite Server):
#         cd /var/www/html/pub/bootstrap/
#         cat bootstrap-<edited_name>.sh | ssh root@<client-hostname> /bin/bash
#
#   ...or...
#
#   (2) in a decentralized manner, executed on each client, via wget or curl:
#         wget -qO- https://<hostname>/pub/bootstrap/bootstrap-<edited_name>.sh | /bin/bash
#         ...or...
#         curl -Sks https://<hostname>/pub/bootstrap/bootstrap-<edited_name>.sh | /bin/bash

# SECURITY NOTE:
#   Use of these scripts via the two methods discussed is the most expedient
#   way to register machines to your Red Hat Satellite Server. Since "wget" is used
#   throughout the script to download various files, a "Man-in-the-middle"
#   attack is theoretically possible.
#
#   The actual registration process is performed securely via SSL, so the risk
#   is minimized in a sense. This message merely serves as a warning.
#   Administrators need to appropriately weigh their concern against the
#   relative security of their internal network.

# PROVISIONING/KICKSTART NOTE:
#   If provisioning a client, ensure the proper CA SSL public certificate is
#   configured properly in the post section of your kickstart profiles (the
#   Red Hat Satellite or hosted web user interface).

# UP2DATE/RHN_REGISTER VERSIONING NOTE:
#   This script will not work with very old versions of up2date and
#   rhn_register.


echo
echo
echo "MINOR MANUAL EDITING OF THIS FILE MAY BE REQUIRED!"
echo
echo "If this bootstrap script was created during the initial installation"
echo "of an Red Hat Satellite, the ACTIVATION_KEYS, and ORG_GPG_KEY values will"
echo "probably *not* be set (see below). If this is the case, please do the"
echo "following:"
echo "  - copy this file to a name specific to its use."
echo "    (e.g., to bootstrap-SOME_NAME.sh - like bootstrap-web-servers.sh.)"
echo "  - on the website create an activation key or keys for the system(s) to"
echo "    be registered."
echo "  - edit the values of the VARIABLES below (in this script) as"
echo "    appropriate:"
echo "    - ACTIVATION_KEYS needs to reflect the activation key(s) value(s)"
echo "      from the website. XKEY or XKEY,YKEY"
echo "    - ORG_GPG_KEY needs to be set to the name(s) of the corporate public"
echo "      GPG key filename(s) (residing in /var/www/html/pub) if appropriate. XKEY or XKEY,YKEY"
echo
echo "Verify that the script variable settings are correct:"
echo "    - CLIENT_OVERRIDES should be only set differently if a customized"
echo "      client-config-overrides-VER.txt file was created with a different"
echo "      name."
echo "    - ensure the value of HOSTNAME is correct."
echo "    - ensure the value of ORG_CA_CERT is correct."
echo
echo "Enable this script: comment (with #'s) this block (or, at least just"
echo "the exit below)"
echo
 

# can be edited, but probably correct (unless created during initial install):
# NOTE: ACTIVATION_KEYS *must* be used to bootstrap a client machine.
ACTIVATION_KEYS=1-a4cba4a8d270f071faef1c5e5c38b5ba
ORG_GPG_KEY=

# can be edited, but probably correct:
CLIENT_OVERRIDES=client-config-overrides.txt
HOSTNAME=usg-rhn4902.autotrader.com

ORG_CA_CERT=rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm
ORG_CA_CERT_IS_RPM_YN=1

USING_SSL=1
USING_GPG=1

REGISTER_THIS_BOX=1

ALLOW_CONFIG_ACTIONS=1
ALLOW_REMOTE_COMMANDS=1

FULLY_UPDATE_THIS_BOX=1

# Set if you want to specify profilename for client systems.
# NOTE: Make sure it's set correctly if any external command is used.
#
# ex. PROFILENAME="foo.example.com"  # For specific clinet system
#     PROFILENAME=`hostname -s`      # Short hostname
#     PROFILENAME=`hostname -f`      # FQDN
PROFILENAME=""   # Empty by default to let it be set automatically.

#
# -----------------------------------------------------------------------------
# DO NOT EDIT BEYOND THIS POINT -----------------------------------------------
# -----------------------------------------------------------------------------
#

# an idea from Erich Morisse (of Red Hat).
# use either wget *or* curl
# Also check to see if the version on the
# machine supports the insecure mode and format
# command accordingly.

if [ -x /usr/bin/wget ] ; then
    output=`LANG=en_US /usr/bin/wget --no-check-certificate 2>&1`
    error=`echo $output | grep "unrecognized option"`
    if [ -z "$error" ] ; then
        FETCH="/usr/bin/wget -q -r -nd --no-check-certificate"
    else
        FETCH="/usr/bin/wget -q -r -nd"
    fi

else
    if [ -x /usr/bin/curl ] ; then
        output=`LANG=en_US /usr/bin/curl -k 2>&1`
        error=`echo $output | grep "is unknown"`
        if [ -z "$error" ] ; then
            FETCH="/usr/bin/curl -SksO"
        else
            FETCH="/usr/bin/curl -SsO"
        fi
    fi
fi
HTTP_PUB_DIRECTORY=http://${HOSTNAME}/pub
HTTPS_PUB_DIRECTORY=https://${HOSTNAME}/pub
if [ $USING_SSL -eq 0 ] ; then
    HTTPS_PUB_DIRECTORY=${HTTP_PUB_DIRECTORY}
fi

INSTALLER=up2date
if [ -x /usr/bin/zypper ] ; then
    INSTALLER=zypper
elif [ -x /usr/bin/yum ] ; then
    INSTALLER=yum
fi
echo
echo "UPDATING RHN_REGISTER/UP2DATE CONFIGURATION FILES"
echo "-------------------------------------------------"
echo "* downloading necessary files"
echo "  client_config_update.py..."
rm -f client_config_update.py
$FETCH ${HTTPS_PUB_DIRECTORY}/bootstrap/client_config_update.py
echo "  ${CLIENT_OVERRIDES}..."
rm -f ${CLIENT_OVERRIDES}
$FETCH ${HTTPS_PUB_DIRECTORY}/bootstrap/${CLIENT_OVERRIDES}

if [ ! -f "client_config_update.py" ] ; then
    echo "ERROR: client_config_update.py was not downloaded"
    exit 1
fi
if [ ! -f "${CLIENT_OVERRIDES}" ] ; then
    echo "ERROR: ${CLIENT_OVERRIDES} was not downloaded"
    exit 1
fi

echo "* running the update scripts"
if [ -f "/etc/sysconfig/rhn/rhn_register" ] ; then
    echo "  . rhn_register config file"
    /usr/bin/python -u client_config_update.py /etc/sysconfig/rhn/rhn_register ${CLIENT_OVERRIDES}
fi
echo "  . up2date config file"
/usr/bin/python -u client_config_update.py /etc/sysconfig/rhn/up2date ${CLIENT_OVERRIDES}

if [ ! -z "$ORG_GPG_KEY" ] ; then
    echo
    echo "* importing organizational GPG key"
    for GPG_KEY in $(echo "$ORG_GPG_KEY" | tr "," " "); do
	rm -f ${GPG_KEY}
	$FETCH ${HTTPS_PUB_DIRECTORY}/${GPG_KEY}
	# get the major version of up2date
	# this will also work for RHEL 5 and systems where no up2date is installed
	res=$(LC_ALL=C rpm -q --queryformat '%{version}' up2date | sed -e 's/\..*//g')
	if [ "x$res" == "x2" ] ; then
	    gpg $(up2date --gpg-flags) --import $GPG_KEY
	else
	    rpm --import $GPG_KEY
	fi
    done
fi

echo
echo "* attempting to install corporate public CA cert"
if [ $ORG_CA_CERT_IS_RPM_YN -eq 1 ] ; then
    rpm -Uvh --force --replacefiles --replacepkgs ${HTTP_PUB_DIRECTORY}/${ORG_CA_CERT}
else
    rm -f ${ORG_CA_CERT}
    $FETCH ${HTTP_PUB_DIRECTORY}/${ORG_CA_CERT}
    mv ${ORG_CA_CERT} /usr/share/rhn/

fi
if [ "$INSTALLER" == zypper ] ; then
    if [  $ORG_CA_CERT_IS_RPM_YN -eq 1 ] ; then
      # get name from config
      ORG_CA_CERT=$(basename $(sed -n 's/^sslCACert *= *//p' /etc/sysconfig/rhn/up2date))
    fi
    test -e "/etc/ssl/certs/${ORG_CA_CERT}.pem" || {
      test -d "/etc/ssl/certs" || mkdir -p "/etc/ssl/certs"
      ln -s "/usr/share/rhn/${ORG_CA_CERT}" "/etc/ssl/certs/${ORG_CA_CERT}.pem"
    }
    test -x /usr/bin/c_rehash && /usr/bin/c_rehash /etc/ssl/certs/ | grep "${ORG_CA_CERT}"
fi

echo
echo "REGISTRATION"
echo "------------"
# Should have created an activation key or keys on the Red Hat Satellite Server's
# website and edited the value of ACTIVATION_KEYS above.
#
# If you require use of several different activation keys, copy this file and
# change the string as needed.
#
if [ -z "$ACTIVATION_KEYS" ] ; then
    echo "*** ERROR: in order to bootstrap RHN clients, an activation key or keys"
    echo "           must be created in the RHN web user interface, and the"
    echo "           corresponding key or keys string (XKEY,YKEY,...) must be mapped to"
    echo "           the ACTIVATION_KEYS variable of this script."
    exit 1
fi

if [ $REGISTER_THIS_BOX -eq 1 ] ; then
    echo "* registering"
    files=""
    directories=""
    if [ $ALLOW_CONFIG_ACTIONS -eq 1 ] ; then
        for i in "/etc/sysconfig/rhn/allowed-actions /etc/sysconfig/rhn/allowed-actions/configfiles"; do
            [ -d "$i" ] || (mkdir -p $i && directories="$directories $i")
        done
        [ -f /etc/sysconfig/rhn/allowed-actions/configfiles/all ] || files="$files /etc/sysconfig/rhn/allowed-actions/configfiles/all"
        [ -n "$files" ] && touch  $files
    fi
    if [ -z "$PROFILENAME" ] ; then
        profilename_opt=""
    else
        profilename_opt="--profilename=$PROFILENAME"
    fi
    /usr/sbin/rhnreg_ks --force --activationkey "$ACTIVATION_KEYS" $profilename_opt
    RET="$?"
    [ -n "$files" ] && rm -f $files
    [ -n "$directories" ] && rmdir $directories
    if [ $RET -eq 0 ]; then
      echo
      echo "*** this system should now be registered, please verify ***"
      echo
    else
      echo
      echo "*** Error: Registering the system failed."
      echo
      exit 1
    fi
else
    echo "* explicitely not registering"
fi

if [ $ALLOW_CONFIG_ACTIONS -eq 1 ] ; then
    echo
    echo "* setting permissions to allow configuration management"
    echo "  NOTE: use an activation key to subscribe to the tools"
    if [ "$INSTALLER" == zypper ] ; then
        echo "        channel and zypper install/update rhncfg-actions"
    elif [ "$INSTALLER" == yum ] ; then
        echo "        channel and yum upgrade rhncfg-actions"
    else
        echo "        channel and up2date rhncfg-actions"
    fi
    if [ -x "/usr/bin/rhn-actions-control" ] ; then
        rhn-actions-control --enable-all
        rhn-actions-control --disable-run
    else
        echo "Error setting permissions for configuration management."
        echo "    Please ensure that the activation key subscribes the"
	if [ "$INSTALLER" == zypper ] ; then
	    echo "    system to the tools channel and zypper install/update rhncfg-actions."
	elif [ "$INSTALLER" == yum ] ; then
            echo "    system to the tools channel and yum updates rhncfg-actions."
        else
            echo "    system to the tools channel and up2dates rhncfg-actions."
        fi
        exit
    fi
fi

if [ $ALLOW_REMOTE_COMMANDS -eq 1 ] ; then
    echo
    echo "* setting permissions to allow remote commands"
    echo "  NOTE: use an activation key to subscribe to the tools"
    if [ "$INSTALLER" == zypper ] ; then
        echo "        channel and zypper update rhncfg-actions"
    elif [ "$INSTALLER" == yum ] ; then
        echo "        channel and yum upgrade rhncfg-actions"
    else
        echo "        channel and up2date rhncfg-actions"
    fi
    if [ -x "/usr/bin/rhn-actions-control" ] ; then
        rhn-actions-control --enable-run
    else
        echo "Error setting permissions for remote commands."
        echo "    Please ensure that the activation key subscribes the"
        if [ "$INSTALLER" == zypper ] ; then
	    echo "    system to the tools channel and zypper updates rhncfg-actions."
	elif [ "$INSTALLER" == yum ] ; then
            echo "    system to the tools channel and yum updates rhncfg-actions."
        else
            echo "    system to the tools channel and up2dates rhncfg-actions."
        fi
        exit
    fi
fi

echo
echo "OTHER ACTIONS"
echo "------------------------------------------------------"
if [ $FULLY_UPDATE_THIS_BOX -eq 1 ] ; then
    if [ "$INSTALLER" == zypper ] ; then
        echo "zypper --non-interactive up zypper zypp-plugin-spacewalk; rhn-profile-sync; zypper --non-interactive up (conditional)"
    elif [ "$INSTALLER" == yum ] ; then
        echo "yum -y upgrade yum yum-rhn-plugin; rhn-profile-sync; yum upgrade (conditional)"
    else
        echo "up2date up2date; up2date -p; up2date -uf (conditional)"
    fi
else
    if [ "$INSTALLER" == zypper ] ; then
        echo "zypper --non-interactive up zypper zypp-plugin-spacewalk; rhn-profile-sync"
    elif [ "$INSTALLER" == yum ] ; then
        echo "yum -y upgrade yum yum-rhn-plugin; rhn-profile-sync"
    else
        echo "up2date up2date; up2date -p"
    fi
fi
echo "but any post configuration action can be added here.  "
echo "------------------------------------------------------"
if [ $FULLY_UPDATE_THIS_BOX -eq 1 ] ; then
    echo "* completely updating the box"
else
    echo "* ensuring $INSTALLER itself is updated"
fi
if [ "$INSTALLER" == zypper ] ; then
    zypper ref -s
    zypper --non-interactive up zypper zypp-plugin-spacewalk
    if [ -x /usr/sbin/rhn-profile-sync ] ; then
        /usr/sbin/rhn-profile-sync
    else
        echo "Error updating system info in Red Hat Satellite."
        echo "    Please ensure that rhn-profile-sync in installed and rerun it."
    fi
    if [ $FULLY_UPDATE_THIS_BOX -eq 1 ] ; then
        zypper --non-interactive up
    fi
elif [ "$INSTALLER" == yum ] ; then
    /usr/bin/yum -y upgrade yum yum-rhn-plugin
    if [ -x /usr/sbin/rhn-profile-sync ] ; then
        /usr/sbin/rhn-profile-sync
    else
        echo "Error updating system info in Red Hat Satellite."
        echo "    Please ensure that rhn-profile-sync in installed and rerun it."
    fi
    if [ $FULLY_UPDATE_THIS_BOX -eq 1 ] ; then
        /usr/bin/yum -y upgrade
    fi
else
    /usr/sbin/up2date up2date
    /usr/sbin/up2date -p
    if [ $FULLY_UPDATE_THIS_BOX -eq 1 ] ; then
        /usr/sbin/up2date -uf
    fi
fi
echo "-bootstrap complete-"
