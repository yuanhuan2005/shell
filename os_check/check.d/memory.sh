#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print memory and swap information by 'free -m':"
	exit 0
fi

free -m
