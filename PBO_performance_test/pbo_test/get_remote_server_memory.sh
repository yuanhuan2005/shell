#!/bin/sh

hosts_file="conf/hosts.conf"
tmp_server_memory=`mktemp`
server_memory="server_memory"
> $tmp_server_memory
> $server_memory

while read LINE
do
	curr_host=`echo $LINE | awk '{print $1}'`
	curr_username=`echo $LINE | awk '{print $2}'`
	curr_password=`echo $LINE | awk '{print $3}'`

	# copy script
	expect -c "
	spawn scp get_local_server_memory.sh ${curr_username}@${curr_host}:
		expect {
			\"*no)?\" {send \"yes\r\"; exp_continue}
			\"*assword:\" {send \"$curr_password\r\"; }
		}
	expect eof;"

	# execute script
	expect -c "
	spawn ssh ${curr_username}@${curr_host} \"sh ~/get_local_server_memory.sh\"
		expect {
			\"*no)?\" {send \"yes\r\"; exp_continue}
			\"*assword:\" {send \"$curr_password\r\"; }
		}
	expect eof;" >> $tmp_server_memory
done < $hosts_file

cat $tmp_server_memory |grep "MEMORY_RATE" | awk '{print $2, $3}' > $server_memory
rm -f $tmp_server_memory
