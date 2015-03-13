#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print mount information by 'mount | column -t':"
	exit 0
fi

mount | column -t
