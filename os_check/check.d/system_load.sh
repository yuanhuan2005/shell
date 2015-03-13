#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print system load information by 'cat /proc/loadavg':"
	exit 0
fi

cat /proc/loadavg
