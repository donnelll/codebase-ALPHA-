#!/bin/sh

# /usr/bin/rsync -avz  /tftpboot/ -e ssh root@%s:/tftpboot

for h in usg-admin3902 tribeca beetle rogue jetta
  do
    /usr/bin/rsync --delete -avz  /tftpboot/ -e ssh root@$h:/tftpboot
  done

