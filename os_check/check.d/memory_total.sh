#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print total memory information by 'grep MemTotal /proc/meminfo':"
	exit 0
fi

grep MemTotal /proc/meminfo
