#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "report file system disk space usage by 'df -h':"
	exit 0
fi

df -h
