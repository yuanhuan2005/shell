#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "tell how long the system has been running by 'uptime':"
	exit 0
fi

uptime
