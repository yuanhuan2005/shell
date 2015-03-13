#!/bin/bash


if [ $# -eq 1 ]
then
	echo -e "print system information by 'uname -a':"
	exit 0
fi

uname -a
