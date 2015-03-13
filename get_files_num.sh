#!/bin/bash

if [ -z "$1" ]
then
	echo "Usage: $0 dir"
	exit 1
fi

num=0

for FILE in `/usr/bin/find "$1"`
do
	num=`expr $num + 1`
done

echo $num files in $1
