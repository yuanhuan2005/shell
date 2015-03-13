#!/bin/bash

cmd="chkconfig --list"
$cmd >/dev/null 2>&1
if [ $? -ne 0 ]
then
	cmd="chkconfig -l"
fi

info="print cron tasks information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
