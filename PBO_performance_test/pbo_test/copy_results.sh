#!/bin/sh

hosts_file="conf/hosts.conf"

while read LINE
do
	curr_host=`echo $LINE | awk '{print $1}'`
	curr_username=`echo $LINE | awk '{print $2}'`
	curr_password=`echo $LINE | awk '{print $3}'`

	# copy results
	expect -c "
	spawn scp ${curr_username}@${curr_host}:~/${curr_host}* .
		expect {
			\"*no)?\" {send \"yes\r\"; exp_continue}
			\"*assword:\" {send \"$curr_password\r\"; }
		}
	expect eof;"
done < $hosts_file
