#!/bin/bash
#Script to get all repositories under a user from bitbucket
#source: http://haroldsoh.com/2011/10/07/clone-all-repos-from-a-bitbucket-source/

# 2017-08-14 Don Lewis: Hacked up script to better parse json output since it likes to string together in one
# line..:/ Also using <user> variable directly and using keys instead of http/https protocol.  Changed API
# call to reflect actual call to list a user's repositories as original URL did not work. Using "slug"
# instead of "name" to parse on since slug reveals true repository name without spaces. 

today=`date '+%Y_%m_%d'`;
repofile="repoinfo"
compressedfile="bitbucket-repos-backup-$today.tgz"
filerun="running.now"
lastrunfile="last.run"

export PATH="$PATH:$HOME/.local/bin:$HOME/bin"

# Create lastruntime file showing last time it was executed
touch $lastrunfile

# Checking to make sure the scripts current run file doesn't exist before running
if [ -e "$filerun" ]
then echo "Looks like we already have a process running....exiting !"
 exit
fi

# Create runtime file showing date/time of initial run and indicates currently running
touch $filerun

# Remove repofile from previous run if still exists from this script's cleanup procedure
echo "Checking to make sure no previous repo file exists before continuing..."
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

# Here we send off the compressed file to Artifactory/S3 for storing and remove local file
# Credential file in home dir of account to be able to statically access S3 bucket
echo "Now sending compressed archive to S3 configured bucket..."
aws s3 cp $compressedfile s3://CAI-Bitbucket-backup
sleep 5
rm -rf $compressedfile
# Remove currently running stat file.
rm -rf $filerun
