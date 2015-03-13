#!/bin/bash

cmd="netstat -antp"
info="print all ESTABLISHED connections information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
