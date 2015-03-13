#!/bin/bash

cmd="netstat -lntp"
info="print all listening ports"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
