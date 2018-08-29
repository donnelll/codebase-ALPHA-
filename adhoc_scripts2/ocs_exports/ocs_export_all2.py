#!/usr/local/bin/python2.7
#!/usr/bin/python
# -*- coding: utf-8 -*-

import MySQLdb as mdb
import csv 
import sys

con = mdb.connect('localhost', 'root', 
        '', 'ocsweb');

with con: 

   cur = con.cursor()
#    cur.execute("SELECT * FROM hardware")
   cur.execute("SELECT h.`NAME`, h.`IPADDR`, h.`OSNAME`, h.`OSVERSION`, h.`PROCESSORS`, h.`PROCESSORT`, h.`PROCESSORN`, h.`MEMORY` FROM hardware h")
   rows = cur.fetchall()

         
   print "%s,%s,%s,%s,%s,%s,%s,%s" % ("HOSTNAME", "IPADDRESS", "OS", "OSVERS", "CPU_MHz", "ARCH", "CPUs", "Memory")

       
   for row in rows:
#      try:    
         hostname = row[0]
	 ipaddr = row[1]
	 osname = row[2]
	 osvers = row[3]
	 cpuspeed = row[4]
	 arch = row[5]
	 cpus = row[6]
	 mem = row[7]

	 print "%s,%s,%s,%s,%s,%s,%s,%s" % (hostname, ipaddr, osname, osvers, cpuspeed, arch, cpus, mem)
#      except IndexError:
#         print hostname
 
