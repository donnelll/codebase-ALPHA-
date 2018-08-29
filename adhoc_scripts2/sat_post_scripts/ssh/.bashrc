# .bashrc
# User specific aliases and functions
#This is required to setup FAST environment variable correctly
pushd /data/esp/bin > /dev/null
source setupenv.sh > /dev/null
popd > /dev/null

#JAVA_HOME=/usr/java/jdk1.6.0_13
JAVA_HOME=/usr/java/jdk1.6.0_13
export JAVA_HOME

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
# Set some aliases
alias ls="ls --color"
alias lg="cd $FASTSEARCH/var/log"
alias dt="cd $FASTSEARCH/data"
#alias vi="vim"
alias ll="ls -l"
