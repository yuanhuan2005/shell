#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print free memory information by 'grep MemFree /proc/meminfo':"
	exit 0
fi

grep MemFree /proc/meminfo
