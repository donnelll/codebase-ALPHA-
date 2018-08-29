#!/bin/bash
/usr/bin/ldapsearch -H ldap://atl6wdc10.na.autotrader.int -Y GSSAPI -N -b "DC=na,DC=autotrader,DC=int" "(&(objectClass=user)(sAMAccountName=ahersi-test))"
