#!/bin/bash

file="/tmp/ipmi_results.out"

ipmitool -U root fru >>$file 
ipmitool -U root sel elist >>$file
ipmitool -U root -v sdr >>$file
ipmitool -U root sdr elist >>$file
ipmitool -U root sdr list >>$file
ipmitool -U root chassis status >>$file
ipmitool -U root sunoem led get >>$file
ipmitool -U root sensor >>$file
ipmitool -U root mc info >>$file
