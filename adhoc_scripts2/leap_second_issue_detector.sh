#!/bin/bash

# Version 1.0.5
# 22 December 2016
# Detect TAI offset incorrect issue

# Version 1.0.4
# 15 December 2016
# Update the regex for matching tinker step.

# Version 1.0.3
# 7 December 2016
# Update the script to support bash on RHEL4 (bash-3.0)

# Version 1.0.2
# 1 December 2016
# Cover the issue that hrtimers may fire early when the leap second is inserted (#2766351).
# 7.3.z: should be kernel-3.10.0-514.2.2.el7 or later
# 7.2.z: should be kernel-3.10.0-327.41.4.el7 or later

# Version 1.0.1
# 28 November 2016
# Navigate each issue detected to a corresponding solution.
# Cover the issue that the ntpd leap status is not reset after inserting a leap second (#1530053).
# Affected versions:
# 'ntp-4.2.6p5-22.el7_2.2'
# 'ntp-4.2.6p5-22.el7_2.1'
# 'ntp-4.2.6p5-22.el7'
# 'ntp-4.2.6p5-19.el7_1.3'
# 'ntp-4.2.6p5-19.el7_1.1'
# 'ntp-4.2.6p5-19.el7_0'
# 'ntp-4.2.6p5-18.el7'
# 'ntp-4.2.6p5-2.el6_5.2'
# 'ntp-4.2.6p5-5.el6_7.5'
# 'ntp-4.2.6p5-5.el6_7.4'
# 'ntp-4.2.6p5-2.el6_5.1'
# 'ntp-4.2.6p5-3.el6_6.1'
# 'ntp-4.2.6p5-5.el6_7.2'
# 'ntp-4.2.6p5-5.el6'
# 'ntp-4.2.6p5-3.el6_6'
# 'ntp-4.2.6p5-2.el6_5'
# 'ntp-4.2.6p5-2.el6_6'
# 'ntp-4.2.6p5-1.el6'

# Version 1.0.0
# 27 October 2016
# For each RHEL 4/5/6/7 there are appropriate tzdata packages that should be installed.
# 4: tzdata-2016g-2.el4
# 5: tzdata-2016g-2.el5
# 6: tzdata-2016g-2.el6
# 7: tzdata-2016g-2.el7
#
# Since the correct version is the same for all major releases, check that the
# installed tzdata rpm is 2016g or later
#
# If there are outdated tzdata packages, check to see if the localtime file indicates
# that the tzdata package needs to be or may need to be updated for the Leap Second.
#
# Check for the proper kernel versions as well - Red Hat Enterprise Linux 4/5/6/7 may have
# potential issues depending on the installed kernel.
#
# For ntp, potential issues with -x or 'slew time' may not work as expected:
# Affected versions:
# 'ntp-4.2.6p5-18.el7'
# 'ntp-4.2.6p5-19.el7_0'
# 'ntp-4.2.6p5-1.el6'
# 'ntp-4.2.6p5-2.el6_6'
# 'ntp-4.2.6p5-2.el6_5'
# 'ntp-4.2.6p5-2.el6_5.1'
# 'ntp-4.2.2p1-[5|7|8].el5'
# 'ntp-.*.el4'
#
# Chrony are all affected up to when publishing the script:
# RHEL 7: chrony-1.1.1-1.el7, chrony-1.29.1-1.el7 and chrony-1.1.1-3.el7 are affected.
# RHEL 6: chrony-1.1.1-1.el6 is affected.
#
# ptp presence is checked and, if Installed, ntp & tzdata checks are skipped,
# but the kernel is still checked

kernelHasIssues=0
alertKernelIssues=0
usingTAI=0
ptpIsRunning=0
ntpdIsRunning=0
chronydIsRunning=0
usingTAI=0
rhelVersion='0'
versionNum=0
affectedBoundaryRhel6_1=0
affectedBoundaryRhel6_2=0
affectedBoundaryRhel6_3=0
affectedBoundaryRhel7_2z=0
affectedBoundaryRhel7_3z=0
kernelIssues=()
kernelIssuesStr=""
usingTaiOffset=0


blue=`tput setaf 4`
reset=`tput sgr0`
echo "${blue}[INFORMATION]${reset}"

uname_info=$( uname -r )
echo "- Installed kernel version: $uname_info"
rhelVersion=$(echo $uname_info | grep -aEo 'el[0-9]+')

# is ptp4l (ie, ptp) running?
if [ $( grep -aEs 'ptp4l' /proc/[0-9]*/cmdline -q; echo $? ) -eq '0' ]; then
    ptpIsRunning=1
fi

# if ptp is running, skip the tzdata & NTP checks
if [ $ptpIsRunning -eq 0 ]; then
    # Is ntpd running?
    if [ $( grep -aEs 'ntpd' /proc/[0-9]*/cmdline -q; echo $? ) -eq '0' ]; then
        ntpdIsRunning=1
    fi

    # Is chronyd running?
    if [ $( grep -aEs 'chronyd' /proc/[0-9]*/cmdline -q; echo $? ) -eq '0' ]; then
        chronydIsRunning=1
    fi

    # Is system using TAI?
    localTime_md5=$( md5sum /etc/localtime | awk '{print $1}' )
    for f in $(find '/usr/share/zoneinfo/right' -type f); do
        compare_md5=$( md5sum $f | awk '{print $1}' )
        if [[ "$localTime_md5" == "$compare_md5" ]]; then
            usingTAI=1
        fi
    done
fi

# do kernel comparisons
# needed versions indicated below
uname_maj=$( echo "$uname_info" | awk -F- '{ print $1 }')
uname_min=$( echo "$uname_info" | awk -F- '{ print $2 }')
IFS=. minor=($uname_min) IFS=

case ${uname_maj} in
"2.6.9")
    # RHEL 4 needs to be after -89
    if [ "${minor[0]}" -lt '89' ]; then
        kernelHasIssues=1
        kernelIssuesStr=$kernelIssuesStr",hang45Issue"
    fi
    ;;
"2.6.18")
    # RHEL 5 needs to be after -164
    if [ "${minor[0]}" -lt '164' ]; then
        kernelHasIssues=1
        kernelIssuesStr=$kernelIssuesStr",hang45Issue"
    fi
    ;;
"2.6.32")
    # RHEL 6 needs to be after -642
    if [ "${minor[0]}" -lt '642' ]; then
        kernelHasIssues=1
        kernelIssuesStr=$kernelIssuesStr",absoluteTimerIssue"
    fi
    # RHEL 6 Affected Versions
    # 6 GA: All Versions -71
    # 6.1: Versions before -131.30.2
    # 6.2: Versions before -220.25.1
    # 6.3: Versions before -279.5.2
    IFS=. minor_1=($(echo "131.30.2")) IFS=
    IFS=. minor_2=($(echo "220.25.1")) IFS=
    IFS=. minor_3=($(echo "279.5.2")) IFS=
    for (( i=0; i<=4; i++ )); do
        versionNum=$[$versionNum+$[${minor[i]}]*(10**(3*(4-$i)))]
        affectedBoundaryRhel6_1=$[$affectedBoundaryRhel6_1+$[${minor_1[i]}]*(10**(3*(4-$i)))]
        affectedBoundaryRhel6_2=$[$affectedBoundaryRhel6_2+$[${minor_2[i]}]*(10**(3*(4-$i)))]
        affectedBoundaryRhel6_3=$[$affectedBoundaryRhel6_3+$[${minor_3[i]}]*(10**(3*(4-$i)))]
    done
    if [[ ${minor[0]} -eq 71 || 
        (${minor[0]} -eq 131 && $versionNum -lt $affectedBoundaryRhel6_1) || 
        (${minor[0]} -eq 220 && $versionNum -lt $affectedBoundaryRhel6_2) || 
        (${minor[0]} -eq 279 && $versionNum -lt $affectedBoundaryRhel6_3) ]]; then
            kernelHasIssues=1
            kernelIssuesStr=$kernelIssuesStr",hightCPUIssue"
    fi
    if [[ (${minor[0]} -eq 131 && $versionNum -lt $affectedBoundaryRhel6_1) || 
        (${minor[0]} -eq 220 && $versionNum -lt $affectedBoundaryRhel6_2) || 
        (${minor[0]} -eq 279 && $versionNum -lt $affectedBoundaryRhel6_3) ]]; then
            kernelHasIssues=1
            kernelIssuesStr=$kernelIssuesStr",hang6Issue"
    fi
    ;;
"3.10.0")
    # RHEL 7 needs to be 514.2.2 and 327.41.4 or later to escape hrtimer issue
    # 7.2.z: Versions -327.41.4 or later
    # 7.3.z: Versions -514.2.2 or later
    IFS=. minor_2z=($(echo "327.41.4")) IFS=
    IFS=. minor_3z=($(echo "514.2.2")) IFS=
    for (( i=0; i<=4; i++ )); do
        versionNum=$[$versionNum+$[${minor[i]}]*(10**(3*(4-$i)))]
        affectedBoundaryRhel7_2z=$[$affectedBoundaryRhel7_2z+$[${minor_2z[i]}]*(10**(3*(4-$i)))]
        affectedBoundaryRhel7_3z=$[$affectedBoundaryRhel7_3z+$[${minor_3z[i]}]*(10**(3*(4-$i)))]
    done
    if [[ !((${minor[0]} -eq 327 && $versionNum -ge $affectedBoundaryRhel7_2z) || 
            (${minor[0]} -eq 514 && $versionNum -ge $affectedBoundaryRhel7_3z)) ]]; then
        kernelHasIssues=1
        kernelIssuesStr=$kernelIssuesStr",hrtimerIssue"
    fi
    # RHEL 7 needs to be after -327 to avoid absoluteTimerIssue
    if [ "${minor[0]}" -lt '327' ]; then
        kernelHasIssues=1
        kernelIssuesStr=$kernelIssuesStr",absoluteTimerIssue"
    fi
esac

# Leap second cases
if [ $ptpIsRunning -eq 1 ] || [ $ntpdIsRunning -eq 1 ] || [ $chronydIsRunning -eq 1 ]; then
    if [ $ptpIsRunning -eq 1 ]; then
        echo "- The system is running PTP."
        if [ $kernelHasIssues -eq 1 ]; then 
            alertKernelIssues=1
        else
            systemInfoLevel="kernelStep"
        fi
    else
        if [ $ntpdIsRunning -eq 1 ]; then
            if [[ $(echo $(ntptime) | grep ' TAI offset 0' -q; echo $?) -ne 0 && $rhelVersion == "el6" ]]; then
                kernelHasIssues=1
                kernelIssuesStr=$kernelIssuesStr",taiOffsetIncorrect"
            fi
            ntpVersion=$( rpm -q --qf '%{name}-%{version}-%{release}.%{arch}\n' ntp )
            echo "- The system is running NTP: $ntpVersion"
            ntpConfigSlew=$( grep -aE '^[^#][^#]*\-[46aAbgLmnNqx]*x[46aAbgLmnNqx]*|^\-[46aAbgLmnNqx]*x[46aAbgLmnNqx]*' /etc/sysconfig/ntpd -q; echo $? )
            ntpRunningSlew=$( echo $(ps aux | grep ntpd) | grep -aE 'ntpd.*\-[46aAbgLmnNqx]*x[46aAbgLmnNqx]*' -q; echo $? )
            if [[ ($ntpConfigSlew -eq '0' && $ntpRunningSlew -eq '0') ||
                $( grep -aE '^[^#][^#]*tinker\s[^#]*step\s|^tinker\s[^#]*step\s' /etc/ntp.conf -q; echo $? ) -eq '0' ]]; then
                # NTP is unning slew mode
                ntpInfoLevel="ntpSlewWithoutIssue"
                # Check if ntp has issues
                slew_affected_version=(
                    'ntp-4.2.6p5-18.el7'
                    'ntp-4.2.6p5-19.el7_0'
                    'ntp-4.2.6p5-1.el6'
                    'ntp-4.2.6p5-2.el6_6'
                    'ntp-4.2.6p5-2.el6_5'
                    'ntp-4.2.6p5-2.el6_5.1'
                    'ntp-4.2.2p1-[5|7|8].el5'
                    'ntp-.*.el4'
                )
                for v in ${slew_affected_version[@]}; do
                    if [ $( echo $ntpVersion | grep -aE $v -q; echo $? ) -eq '0' ]; then
                        ntpInfoLevel="ntpSlewWithIssues"
                        break
                    fi
                done 
                if [[ $rhelVersion == "el4" && $kernelHasIssues -eq 1 ]]; then 
                    alertKernelIssues=1
                fi
            elif [[ ($ntpConfigSlew -eq '0' && $ntpRunningSlew -ne '0') || 
                ($ntpConfigSlew -ne '0' && $ntpRunningSlew -eq '0') ]]; then
                ntpInfoLevel="configNEDaemon"
            else # ntp default mode
                reset_affected_version=(
                     'ntp-4.2.6p5-22.el7_2.2'
                     'ntp-4.2.6p5-22.el7_2.1'
                     'ntp-4.2.6p5-22.el7'
                     'ntp-4.2.6p5-19.el7_1.3'
                     'ntp-4.2.6p5-19.el7_1.1'
                     'ntp-4.2.6p5-19.el7_0'
                     'ntp-4.2.6p5-18.el7'
                     'ntp-4.2.6p5-2.el6_5.2'
                     'ntp-4.2.6p5-5.el6_7.5'
                     'ntp-4.2.6p5-5.el6_7.4'
                     'ntp-4.2.6p5-2.el6_5.1'
                     'ntp-4.2.6p5-3.el6_6.1'
                     'ntp-4.2.6p5-5.el6_7.2'
                     'ntp-4.2.6p5-5.el6'
                     'ntp-4.2.6p5-3.el6_6'
                     'ntp-4.2.6p5-2.el6_5'
                     'ntp-4.2.6p5-2.el6_6'
                     'ntp-4.2.6p5-1.el6'
                )
                for v in ${reset_affected_version[@]}; do
                    if [ $( echo $ntpVersion | grep -aE $v -q; echo $? ) -eq '0' ]; then
                        ntpInfoLevel="ntpResetIssues"
                        break
                    fi
                done 
                if [ $kernelHasIssues -eq 1 ]; then 
                    alertKernelIssues=1
                else
                    systemInfoLevel="kernelStep"
                fi
            fi
        fi

        if [ $chronydIsRunning -eq 1 ]; then
            chronyVersion=$( rpm -q --qf '%{name}-%{version}-%{release}.%{arch}\n' chrony )
            echo "- The system is running chronyd: $chronyVersion"
            # Check chrony leapsecmode
            chronyLeapsecMode=$(grep -aE '^[^#][^#]*leapsecmode\s|^leapsecmode\s' /etc/chrony.conf | awk '{printf $2}')
            case $chronyLeapsecMode in
                "slew" )
                    chronyInfoLevel="chronySlew"
                    ;;
                "step" )
                    systemInfoLevel="chronyStep"
                    ;;
                "ignore" )
                    chronyInfoLevel="chronyIgnore"
                    ;;
                * )
                    # default chronyLeapsecMode='system' for rhel
                    if [ $kernelHasIssues -eq 1 ]; then 
                        alertKernelIssues=1
                    else
                        systemInfoLevel="kernelStep"
                    fi
                    ;;
            esac
            if [ $( grep -aE '^[^#][^#]*smoothtime\s[^#]*leaponly|^smoothtime\s[^#]*leaponly' /etc/chrony.conf -q; echo $?) -eq 0 ] && [ $chronyLeapsecMode == 'slew' ]; then
                chronyInfoLevel="chronySmear"
                if [ $( echo $chronyVersion | grep -aE 'chrony-2.1.1-[1|3].el7|chrony-1.29.1-1.el7|chrony-2.1.1-1.el6' -q; echo $? ) -eq '0' ]; then
                    chronyInfoLevel="chronyCrash"
                fi
            fi
        fi
    fi
    if [ $usingTAI -eq 1 ]; then
        echo "- Meanwhile, the system is using the 'right/*' timezone info."
        tzdataInfoLevel='TAIorNTP'
    fi
elif [ $usingTAI -eq 1 ]; then
    systemInfoLevel="onlyTAI"
    tadataVersion=$( rpm -q --qf '%{name}-%{version}-%{release}.%{arch}\n' tzdata )
    echo "- Installed tzdata version: $tadataVersion"
    echo "- The system is using the 'right/*' timezone info."
    if [ $( rpm -qa | grep -aE tzdata-2016[g-z] -q; echo $? ) -ne 0 ]; then
        tzdataInfoLevel='tzdataUpdate'
    fi
else
    systemInfoLevel="incorrect"
fi

case $systemInfoLevel in
    "onlyTAI" )
        echo "The system will learn about the leapsecond from an updated tzdata package. Any application that expects the time to be in UTC will have issues if a right/* timezone is used. If that is not desired, consult <https://access.redhat.com/articles/15145> for details on configuring the system."
        ;;
    "chronyStep" )
        echo "The clock will be stepped by chrony daemon."
        ;;
    "kernelStep" )
        echo "When the leap second occurs, this systems time will be stepped by the kernel. Thus, it is configured to stay in sync with the true/official time."
        ;;
    "incorrect" )
        echo "After the leap second, this system will have a time which is different from the true/official time. If that is not desired, consult <https://access.redhat.com/articles/15145> for details on configuring the system."
        ;;
esac

if [ $alertKernelIssues -eq 1 ]; then
    IFS=, kernelIssues=($kernelIssuesStr) IFS=
    echo "When the leap second occurs, this systems time will be stepped by the kernel. Thus, it is configured to stay in sync with the true/official time."
    echo "${blue}[SUGGESTIONS ON KERNEL]${reset}"
    if [[ ${#kernelIssues[@]} == 2 ]]; then
        echo "A known issue of kernel is detected and listed below. Refer to the link attached for the remediation steps."
    else
        echo "Known issues of kernel are detected and listed below. Refer to the link attached for the remediation steps."
    fi
    for issue in ${kernelIssues[@]}; do
        case $issue in 
            "hrtimerIssue" )
                echo "- There is a chance that hrtimers may fire early when the leap second is inserted; this issue is documented in <https://access.redhat.com/solutions/2766351>."
                ;;
            "absoluteTimerIssue" )
                echo "- Absolute timers may fire early when the leap second is inserted; this issue is documented in <https://access.redhat.com/solutions/1471933>."
                ;;
            "hang6Issue" )
                echo "- There is a chance that a system can hang once it receives notification of the insertion of a leap second; this issue is documented in <https://access.redhat.com/solutions/154713>."
                ;;
            "hightCPUIssue" )
                echo "- After the leap second has been inserted futex heavy applications began consuming a large amount of CPU; this issue is documented in <https://access.redhat.com/solutions/154793>."
                ;;
            "hang45Issue" )
                echo "- There is a chance that the printing of this message can cause the kernel to crash; this issue is documented in <https://access.redhat.com/solutions/1325313>."
                ;;
            "taiOffsetIncorrect" )
                echo "- The TAI offset is not updated correctly during the leap second; this issue is documented in <https://access.redhat.com/solutions/1380403>."
                ;;
        esac
    done
fi

if [ $ntpInfoLevel ]; then
    echo "${blue}[SUGGESTIONS ON NTP]${reset}"
fi
case $ntpInfoLevel in
    "ntpSlewWithIssues" )
        echo "NTP is running slew mode."
        echo "A known issue of ntp is detected and listed below. Refer to the link attached for the remediation steps."
        case $rhelVersion in
            "el4" )
                echo "- Slew mode does not prevent ntp from setting the kernel flag; this issue is documented in <https://access.redhat.com/solutions/1507793>."
                ;;
            "el5" )
                echo "- When running ntp in slew mode time is not adjusted properly by the leap second; this is documented in <https://access.redhat.com/solutions/68712>."
                ;;
            "el6" )
                echo "- Using -x with ntp still results in instantaneous clock changes when leap second occurs; this issue is documented in <https://access.redhat.com/solutions/1379783>."
                ;;
            "el7" )
                echo "- Using -x with ntp still results in instantaneous clock changes when leap second occurs; this issue is documented in <https://access.redhat.com/solutions/1379783>."
                ;;
        esac
        ;;
    "ntpSlewWithoutIssue" )
        echo "NTPd is running in slew mode. This means, the system clock will not be stepped, but slewed. Due to this configuration, ntpd can not be used as an NTP server for other clients."
        ;;
    "configNEDaemon" )
        echo 'Configuration in /etc/sysconfig/ntpd does not take effect in ntp deamon. You may need to check the configurations or restart ntp service.'
        ;;
    "ntpResetIssues" )
        echo "A known issue of ntp is detected and listed below. Refer to the link attached for the remediation steps."
        echo '- The ntpd leap status is not reset after inserting a leap second. Refer to <https://access.redhat.com/solutions/1530053> for more details.'
        ;;
esac

case $chronyInfoLevel in
    "chronySmear" )
        echo "${blue}[SUGGESTIONS ON CHRONY]${reset}"
        echo "Chrony has smearing of leap seconds enabled. In this setting, the server is intentionally not serving its best estimate of the true/official time. Clients receiving this signal will have a different idea about the time than systems operating under the true/official time. This should be considered if systems from both modes of operation are communicating with each other. Also, it would probably be a bad idea to configure this mode on an NTP server for other clients."
        ;;
    "chronySlew" )
        echo "Chrony is running slew mode. The local clock is corrected by slew, while the time served to NTP clients is stepped on leap second."
        ;;
    "chronyIgnore" )
        echo "${blue}[SUGGESTIONS ON CHRONY]${reset}"
        echo "Chrony selects a mode where no correction is made for the leap second itself and the clock is corrected later in normal NTP operation. It cannot serve as an NTP server for other clients."
        ;;
    "chronyCrash" )
        echo "${blue}[SUGGESTIONS ON CHRONY]${reset}"
        echo "A known issue of chrony is detected and listed below. Refer to the link attached for the remediation steps."
        echo "- There is a chance that chronyd may crash when smearing the leap second, consult <https://access.redhat.com/solutions/2759021> for details." 
        echo "Chrony has smearing of leap seconds enabled. In this setting, the server is intentionally not serving its best estimate of the true/official time. Clients receiving this signal will have a different idea about the time than systems operating under the true/official time. This should be considered if systems from both modes of operation are communicating with each other. Also, it would probably be a bad idea to configure this mode on an NTP server for other clients."
        ;;
esac

case $tzdataInfoLevel in
    'tzdataUpdate' )
        echo "${blue}[SUGGESTIONS ON TZDATA]${reset}"
        echo "System should update the tzdata to tzdata-2016g-2.$rhelVersion, or a later version, to recognize the leap second."
        ;;
    'TAIorNTP' )
        echo "${blue}[SUGGESTIONS ON TIMEZONE]${reset}"
        echo "The system is using the 'right/*' timezone info while running NTP/PTP. In any case, NTP modified to use a different timescale than UTC/POSIX would be against the NTP specification."
        ;;
esac