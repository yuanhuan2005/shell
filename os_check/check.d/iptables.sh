#!/bin/bash

cmd="iptables -L"
info="print firewall information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
