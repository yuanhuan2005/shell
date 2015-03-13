#!/bin/sh

total=`free -m | grep "Mem:" | awk '{print $2}'`
free=`free -m | grep "cache:" | awk '{print $3}'`
mem_rate=`echo "" | awk -v total=$total -v free=$free 'END{print free/total*100, "%"}'`
ip_addr=`/sbin/ifconfig |grep "inet addr" |sed 's/:/ /g' | awk '{print $3}' | head -n 1`
echo "MEMORY_RATE ${ip_addr} ${mem_rate}"
