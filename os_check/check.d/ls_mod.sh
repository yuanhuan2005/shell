#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print kernel modules information by 'lsmod':"
	exit 0
fi

lsmod
