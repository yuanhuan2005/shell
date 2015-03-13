#!/bin/bash

cmd="ps -ef"
info="print all processes information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
