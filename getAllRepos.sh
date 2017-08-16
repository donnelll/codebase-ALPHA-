#!/bin/bash
#Script to get all repositories under a user from bitbucket
#Usage: getAllRepos.sh [username]
#source: http://haroldsoh.com/2011/10/07/clone-all-repos-from-a-bitbucket-source/

# 2017-08-14 Don Lewis: Hacked up script to better parse json output since it likes to string together in one
# line..:/ Also using <user> variable directly and using keys instead of http/https protocol.  Changed API
# call to reflect actual call to list a user's repositories as original URL did not work. Using "slug"
# instead of "name" to parse on since slug reveals true repository name without spaces. 

repofile="repoinfo" 

# Remove repofile from previous run if still exists from this script's cleanup procedure
if [ -e "$repofile" ]
then
  rm -rf $repofile
fi

#OLD URL:curl -u ${1} https://api.bitbucket.org/1.0/users/${1} > repoinfo
curl --user dlewis1 https://api.bitbucket.org/1.0/user/repositories > $repofile 


# cat repoinfo
for repo_name in `cat repoinfo | sed -r 's/("slug": )/\n\1/g' | sed -r 's/"slug": "(.*)"/\1/' | sed -e 's/{//' | cut -f1 -d\" | tr '\n' ' '`
do
    echo "Cloning " $repo_name
    #git clone https://dlewis1@bitbucket.org/coxauto/$repo_name
    git clone git@bitbucket.org:coxauto/$repo_name
    echo "---"
done

# Cleanup repofile from current directory 
if [ -e "$repofile" ]
then
  rm -rf $repofile
fi
