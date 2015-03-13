#!/bin/bash

dir="/var"

if [ $# -eq 1 ]
then
	echo -e "print disk usage of $dir by 'du -sh $dir':"
	exit 0
fi

du -sh $dir
