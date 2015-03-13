#!/bin/bash

cmd="cut -d: -f1 /etc/passwd"
info="print system users information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
