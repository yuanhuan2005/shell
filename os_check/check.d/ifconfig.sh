#!/bin/bash

cmd="ifconfig"
info="print network interface information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
