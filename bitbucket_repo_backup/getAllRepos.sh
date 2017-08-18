#!/bin/bash
#Script to get all repositories under a user from bitbucket
#Usage: getAllRepos.sh [username]
#source: http://haroldsoh.com/2011/10/07/clone-all-repos-from-a-bitbucket-source/

# 2017-08-14 Don Lewis: Hacked up script to better parse json output since it likes to string together in one
# line..:/ Also using <user> variable directly and using keys instead of http/https protocol.  Changed API
# call to reflect actual call to list a user's repositories as original URL did not work. Using "slug"
# instead of "name" to parse on since slug reveals true repository name without spaces. 

today=`date '+%Y_%m_%d'`;
repofile="repoinfo"
compressedfile="bitbucket-repos-backup-$today.tgz"

# Remove repofile from previous run if still exists from this script's cleanup procedure
echo "Checking to make sure no previous run file exists before continuing..."
if [ -e "$repofile" ]
then
  rm -rf $repofile
fi

# Making API call to Bitbucket using randomly gnerated APP password for account access instead
# of the actual account password; this provides security as the APP password has a "role"
# assigned with only certain permissions. This puts the json API repository info into a file
# that will be parsed.
echo "Making API call to Bitbucket and grabbing all repository information under user account..."
curl --user dlewis1:u5Kd2RP2wBPuZPye9mqa https://api.bitbucket.org/1.0/user/repositories > $repofile

# cat repoinfo file and pattern match for "slug" name which is the "true" repository name known to the system and then clones a copy locally of all of them.
echo "Cloning all repositories listed in $repofile..."
for repo_name in `cat repoinfo | sed -r 's/("slug": )/\n\1/g' | sed -r 's/"slug": "(.*)"/\1/' | sed -e 's/{//' | cut -f1 -d\" | tr '\n' ' '`
do
    echo "Cloning " $repo_name
    git clone git@bitbucket.org:coxauto/$repo_name
    echo "---"
done


# Cleanup repofile from current directory 
echo "Removing run file from local directory signifying that the run is complete..."
if [ -e "$repofile" ]
then
  rm -rf $repofile
fi

# Compress all cloned repositories
echo "Compressing results file $compressedfile..."
tar --exclude getAllRepos.sh -czvf $compressedfile *

# Cleanup and remove all repository directories after they have been compressed
echo "Removing all locally cloned repository directories..."
find . -type d -exec rm -rf {} +

# Here we send off the compressed file to Artifactory for storing and remove local file
