#!/bin/bash

cmd="w"
info="print active users information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
