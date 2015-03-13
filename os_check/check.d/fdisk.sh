#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print manipulate disk partition table information by 'fdisk -l':"
	exit 0
fi

fdisk -l
