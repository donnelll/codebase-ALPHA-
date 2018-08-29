#!/bin/bash

dbs="pdb7008 pdb7018 pdb7020 pdb7022 pdb7024"
volumes="/u024/oradata/ATCS1 /u006/oradata/ATCS1 /u011/oradata/ATCS1 /u022/oradata/ATCS1 /u023/oradata/ATCS1 /u005/oradata/ATCS1 /u024/oradata/ATDCR1 /u006/oradata/ATDCR1 /u011/oradata/ATDCR1 /u022/oradata/ATDCR1 /u023/oradata/ATDCR1 /u005/oradata/ATDCR1 /u024/oradata/ATMDM1 /u006/oradata/ATMDM1 /u011/oradata/ATMDM1 /u022/oradata/ATMDM1 /u023/oradata/ATMDM1 /u005/oradata/ATMDM1 /u009 /u024/oradata/ATSVOC /u006/oradata/ATSVOC /u011/oradata/ATSVOC /u022/oradata/ATSVOC /u023/oradata/ATSVOC /u005/oradata/ATSVOC /migrate /backup /u031 /u021 /u021_pdb7018 /u021_pdb7020"

for i in $dbs;
	do ssh $i umount $volumes;
done
