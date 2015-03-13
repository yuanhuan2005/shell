#!/bin/bash

cmd="top -n 1"
info="print top(CPU/Memory/IO) information once"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
