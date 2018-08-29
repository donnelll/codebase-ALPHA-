#!/bin/bash
/sbin/service sssd stop
sss_cache -E

/sbin/service sssd stop
rm -fr /var/lib/sss/db/*
rm -fr /var/lib/sss/mc/*
rm -fr /var/log/sssd/*
/bin/sleep 2
/sbin/service sssd start
