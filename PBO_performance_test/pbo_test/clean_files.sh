#!/bin/sh


hosts_file="conf/hosts.conf"

file_list=""
while read LINE
do
	curr_host=`echo $LINE | awk '{print $1}'`
	file_list="${file_list} ${curr_host}* "
done < $hosts_file

rm -rf ${file_list} jmeter.log logs/* server_memory *.jmx *.jtl

while read LINE
do
	curr_host=`echo $LINE | awk '{print $1}'`
	curr_username=`echo $LINE | awk '{print $2}'`
	curr_password=`echo $LINE | awk '{print $3}'`

	# delete results
	expect -c "
	spawn ssh ${curr_username}@${curr_host} \"rm -f ${file_list} *nmon\"
		expect {
			\"*no)?\" {send \"yes\r\"; exp_continue}
			\"*assword:\" {send \"$curr_password\r\"; }
		}
	expect eof;"
done < $hosts_file
