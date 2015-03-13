#!/bin/bash

cmd="swapon -s"

if [ $# -eq 1 ]
then
	echo -e "print swap information by '$cmd':"
	exit 0
fi

$cmd
