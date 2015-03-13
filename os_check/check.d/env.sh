#!/bin/bash

if [ $# -eq 1 ]
then
	echo -e "print environment information by 'env':"
	exit 0
fi

env
