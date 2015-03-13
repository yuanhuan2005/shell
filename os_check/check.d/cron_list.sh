#!/bin/bash

cmd="crontab -l"
info="print cron tasks information"

if [ $# -eq 1 ]
then
	echo -e "$info by '$cmd':"
	exit 0
fi

$cmd
