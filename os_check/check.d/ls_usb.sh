#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print USB information by 'lsusb -tv':"
	exit 0
fi

lsusb -tv
