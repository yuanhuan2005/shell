#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print hostname by 'hostname':"
	exit 0
fi

hostname
