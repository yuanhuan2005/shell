#!/bin/bash


if [ $# -ne 2 ]
then
	echo "Usage: $0 file1 file2"
	exit 1
fi

file1="$1"
file2="$2"

if [ ! -e ${file1} ]
then
	echo "Error: $file1 not found"
	exit 1
fi

if [ ! -e ${file2} ]
then
	echo "Error: $file2 not found"
	exit 1
fi

if [ ! -f ${file1} ]
then
	echo "Error: $file1 not file"
	exit 1
fi

if [ ! -f ${file2} ]
then
	echo "Error: $file2 not file"
	exit 1
fi

# cpmpare inode ID
ino_file1=`ls -li ${file1} | awk '{print $1}'`
ino_file2=`ls -li ${file2} | awk '{print $1}'`
if [ "${ino_file1}" == "${ino_file2}" ]
then
	echo "Same files"
	exit 0
fi

# diff
diff ${file1} ${file2} > /dev/null 2>&1
ret=$?
if [ $ret -eq 0 ]
then
	echo "Same files"
	exit 0
fi


echo "Not same files"
exit 1
