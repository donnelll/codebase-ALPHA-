#!/bin/bash
# THIS IS ONLY NEEDED IF VM USES THE VMXNET 2/3 DRIVER!
#Auth:Abdi
#Auto-recompile VM Tools when kernel updated - yum update kernel
VMToolsCheckFile="/lib/modules/`uname -r`/misc/.vmware_installed"
VMToolsVersion=`vmware-config-tools.pl --help 2>&1 | awk '$0 ~ /^VMware Tools [0-9]/ { print $3,$4 }'`

echo -e "\nCurrent VM Tools version: $VMToolsVersion\n\n"

 if [[ ! -e $VMToolsCheckFile || `grep -c "$VMToolsVersion" $VMToolsCheckFile` -eq 0 ]]; then
 [ -x /usr/bin/vmware-config-tools.pl ] && \
 echo -e  "Automatically compiling new build of VMware Tools\n\n" && \
 /usr/bin/vmware-config-tools.pl --default && \
 echo  "$VMToolsVersion" > $VMToolsCheckFile && \
 rmmod pcnet32
 rmmod vmxnet
 depmod -a
 modprobe vmxnet
 fi
