#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print CPU information by 'cat /proc/cpuinfo':"
	exit 0
fi

cat /proc/cpuinfo
