#!/bin/bash

## This script is being written to present EOC/NOC personnel with a menu of locations they want to pull logs for per a restricted menu-Donnell Lewis##

bin=/bin/ksh
runscript="/data/home/logmgr/ast/arch/SunOS-5.10.i386/bin/ksh $HOME/scripts/logpull-1.0/bin/logpull.ksh -c"
conf_path="/data/home/logmgr/scripts/logpull-1.0/conf"
#search="sed -n -e "s/.*\($HOST\).*/\1/p" $conf_path*"

# Here we declare our simple arrays
acsite=( logpull_chassis.production9200 )
ccsite=( logpull.atx-consumer )
adc=( logpull.\8100 logpull.\9100 )
cdc=( logpull.atx-dealersite )
syc=( logpull.syc )
pidg=( logpull.pidg logpull.pidg4100 )
ice=( logpull.ice )
fastl=( logpull.frontline logpull.frp7200 logpull.frp7100 logpull.frp7600 logpull.frp7300 logpull.frp7508 )

# Here we get number of elements in each array for parsing purposes
acsite_el=${#acsite[@]}
ccsite_el=${#ccsite[@]}
adc_el=${#adc[@]}
cdc_el=${#cdc[@]}
syc_el=${#syc[@]}
pidg_el=${#pidg[@]}
ice_el=${#ice[@]}
fastl_el=${#fastl[@]}

# Audit script variables
audit2="/site/packages/logaudit-1.0/bin/logaudit.sh -e ' donnell.lewis@autotrader.com' -a 'consumer site' -t today -r hourly -f access_log9[23]00.\%y\%m\%d-\%H0000.gz -d '/vue/logs/web*9*/access' > /dev/null 2>&1"

# Clear screen and wait for something to happen...(Tucker would love this line.;p)
tput clear


# Ask for an example system we are looking to pull logs for to make sure it exists before all the trouble
#echo -n "What is the hostname you are wanting to pull a logpull for ? []: "
#read HOST
#if [ -z "$HOST" ]; then
#  echo "Nothing entered, exiting!"
#   exit
#fi

echo "1) Autotrader Consumer Site"
echo "2) Classics Consumer Site"
echo "3) Autotrader Dealer Community"
echo "4) Classics Dealer Community"
echo "5) Sell Your Car"
echo "6) Pidgets"
echo "7) ICE"
echo "8) Fastlane"
# Individual host will be a seclection once template has been built that can be used with -h option

echo -n "Please select environment to pull logs for []: "
read hcase;

#### Define expressions 
case $hcase in
	1) echo "These configs will be ran:"
		for (( i=0;i<$acsite_el;i++ ));
		     do	echo "${acsite[${i}]}";done
	echo -n "Do you want to continue ? [y/n]: "
	 read a1
		if [ -z "$a1" ]; then
		 echo "No choice made..exiting"
			elif
			  [ "$a1" = "y" ]; then
			for (( i=0;i<acsite_el;i++ ));
				do
				exec $runscript ${acsite[${i}]};done 	
			 		else echo "...Exiting"
			   exit
	fi  ;;
		 

	2) echo "These configs will be ran:"
		 for (( i=0;i<$ccsite_el;i++ )); 
		      do echo "${ccsite[${i}]}";done
	echo -n "Do you want to continue ? [y/n]: "
	 read a2
		if [ -z "$a2" ]; then
		 echo "No choice made..exiting"
			elif
			  [ "$a2" = "y" ]; then
			for (( i=0;i<ccsite_el;i++ ));
				do
				exec $runscript ${ccsite[${i}]};done
				 exec $audit2
					else echo "...Exiting"
				exit
	fi ;;


	3) echo "These configs will be ran:"
                 for (( i=0;i<$adc_el;i++ ));
                      do echo "${adc[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<adc_el;i++ ));
                                do
                                exec $runscript ${adc[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;
 

	4) echo "These configs will be ran:"
                 for (( i=0;i<$cdc_el;i++ ));
                      do echo "${cdc[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<cdc_el;i++ ));
                                do
                                exec $runscript ${cdc[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;
	

	5) echo "These configs will be ran:"
                 for (( i=0;i<$syc_el;i++ ));
                      do echo "${syc[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<syc_el;i++ ));
                                do
                                exec $runscript ${syc[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;


	6) echo "These configs will be ran:"
                 for (( i=0;i<$pidg_el;i++ ));
                      do echo "${pidg[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<pidg_el;i++ ));
                                do
                                exec $runscript ${pidg[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;


	7) echo "These configs will be ran:"
                 for (( i=0;i<$ice_el;i++ ));
                      do echo "${ice[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<ice_el;i++ ));
                                do
                                exec $runscript ${ice[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;


	8) echo "These configs will be ran:"
                 for (( i=0;i<$fastl_el;i++ ));
                      do echo "${fastl[${i}]}";done
        echo -n "Do you want to continue ? [y/n]: "
         read a3
                if [ -z "$a3" ]; then
                 echo "No choice made..exiting"
                        elif
                          [ "$a3" = "y" ]; then
                        for (( i=0;i<fastl_el;i++ ));
                                do
                                exec $runscript ${fastl[${i}]};done
                                        else echo "...Exiting"
                                exit
        fi ;;
esac

