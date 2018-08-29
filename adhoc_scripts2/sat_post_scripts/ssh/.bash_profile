#bring in our bashrc file
[ -f ~/.bashrc ] && . ~/.bashrc


#Handle OS Specific Stuff
osname=`uname`
if [ "xxx$osname" = "xxxSunOS" ]; then
  export TERM=xterm
fi

#General Exports
export PAGER=less

FASTSEARCH=/data/esp
#Consumer Site and MDM
#PATH=$PATH:/data/esp/bin:$HOME/bin:/usr/bin:/usr/sbin:/bin:/usr/bin/java:/usr/java/jdk1.6.0_13/bin
#JAVA_HOME=/usr/java/jdk1.6.0_13
#ATX
PATH=$PATH:/data/esp/bin:$HOME/bin:/usr/bin:/usr/sbin:/bin:/usr/bin/java:/usr/java/jdk1.6.0_13/bin
JAVA_HOME=/usr/java/jdk1.6.0_13

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib:/usr/lib64

export PATH LD_LIBRARY_PATH FASTSEARCH JAVA_HOME

#source any scopus specific stuff
[ -f ~/.scopusrc ] && . ~/.scopusrc

export PS1="\[\033[01;32m\]\u@\h\[\033[01;34m\] \w \$\[\033[00m\] "
