#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print PCI information by 'lspci -tv':"
	exit 0
fi

lspci -tv
