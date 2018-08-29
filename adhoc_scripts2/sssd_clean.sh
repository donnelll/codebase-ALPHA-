#!/bin/bash
/bin/systemctl stop  sssd.service
sss_cache -E
rm -fr /var/lib/sss/db/*
rm -fr /var/lib/sss/mc/*
/bin/sleep 2
/bin/systemctl start  sssd.service
/bin/sleep 1
/bin/systemctl status  sssd.service
