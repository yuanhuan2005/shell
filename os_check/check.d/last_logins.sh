#!/bin/bash

cmd="last"
info="print last login information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
