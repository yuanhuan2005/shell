#!/bin/bash

cmd="route -n"
info="print route information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
