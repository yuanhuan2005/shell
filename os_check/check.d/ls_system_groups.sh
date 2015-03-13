#!/bin/bash

cmd="cut -d: -f1 /etc/group"
info="print system groups information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
