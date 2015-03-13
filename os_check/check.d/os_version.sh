#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print os version by 'head -n 1 /etc/issue':"
	exit 0
fi

head -n 1 /etc/issue
