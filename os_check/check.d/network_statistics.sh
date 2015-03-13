#!/bin/bash

cmd="netstat -s"
info="print network statistics information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
