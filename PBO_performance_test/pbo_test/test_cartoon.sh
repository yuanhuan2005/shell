#!/bin/sh

current_date=`date +%Y%m%d%H%M%S`
channel_name="cartoon"
channel_id=3
log_file="logs/${channel_name}_${current_date}.log"
SECOND=1
TIME=20
echo "" >> $log_file
echo "" >> $log_file
echo "" >> $log_file
date >> $log_file
date

while read LINE
do
	concurrency=$LINE
	echo ">>>>>>>>>>>   concurrency=$concurrency   begin  >>>>>>>>>" >> $log_file
	echo ">>>>>>>>>>>   concurrency=$concurrency   begin  >>>>>>>>>"
	if [ ! -e conf/coverId_${channel_name} ]
	then
		echo "Error : conf/coverId_${channel_name} does not exist" >> $log_file
		echo "Error : conf/coverId_${channel_name} does not exist"
		continue
	fi

	if [ ! -e jmx/PBO_${channel_name}_${concurrency}.jmx ]
	then
		echo "Error : jmx/PBO_${channel_name}_${concurrency}.jmx does not exist" >> $log_file
		echo "Error : jmx/PBO_${channel_name}_${concurrency}.jmx does not exist"
		continue
	fi


	echo "File check successfully" >> $log_file
	echo "File check successfully"

	cp conf/coverId_${channel_name} /tmp/userId_coverId.txt
	echo "~/apache-jmeter-2.9/bin/jmeter -n -t jmx/PBO_${channel_name}_${concurrency}.jmx -l jmeter_${channel_name}_${concurrency}.jtl &" >> $log_file
	echo "~/apache-jmeter-2.9/bin/jmeter -n -t jmx/PBO_${channel_name}_${concurrency}.jmx -l jmeter_${channel_name}_${concurrency}.jtl &"
	~/apache-jmeter-2.9/bin/jmeter -n -t jmx/PBO_${channel_name}_${concurrency}.jmx -l jmeter_${channel_name}_${concurrency}.jtl &

	sleep 3


	hosts_file="conf/hosts.conf"
	while read LINE
	do
		curr_host=`echo $LINE | awk '{print $1}'`
		curr_username=`echo $LINE | awk '{print $2}'`
		curr_password=`echo $LINE | awk '{print $3}'`

		# copy nmon to remote host
		echo "copy nmon to ${curr_username}@${curr_host}" >> $log_file
		expect -c "
		spawn scp nmon ${curr_username}@${curr_host}:/tmp/
			expect {
				\"*no)?\" {send \"yes\r\"; exp_continue}
				\"*assword:\" {send \"$curr_password\r\"; }
			}
		expect eof;"

		# start nmon
		echo "start nmon on ${curr_username}@${curr_host}" >> $log_file
		expect -c "
		spawn ssh ${curr_username}@${curr_host} \"chmod +x /tmp/nmon ; /tmp/nmon -s $SECOND -c $TIME -f & \"
			expect {
				\"*no)?\" {send \"yes\r\"; exp_continue}
				\"*assword:\" {send \"$curr_password\r\"; }
			}
		expect eof;"
	done < $hosts_file


	echo "Starting check jmeter process is running or not." >> $log_file
	echo "Starting check jmeter process is running or not." 
	while true
	do
		jmeter_num=`ps -ef |grep -i jmeter |grep -v grep | wc -l`
		if [ $jmeter_num -eq 0 ]
		then
			break
		fi

		echo "JMeter is still running, waiting for next check." >> $log_file
		echo "JMeter is still running, waiting for next check."
		sleep 10
	done

	sleep 300



	while read LINE
	do
		curr_host=`echo $LINE | awk '{print $1}'`
		curr_username=`echo $LINE | awk '{print $2}'`
		curr_password=`echo $LINE | awk '{print $3}'`

		# generate csv on remote host
		echo "generate csv on ${curr_username}@${curr_host}" >> $log_file
		expect -c "
		spawn ssh ${curr_username}@${curr_host} \"sort *.nmon > ${curr_host}_channelId_${channel_name}_concurrency_${concurrency}.csv ; rm -f *nmon\"
			expect {
				\"*no)?\" {send \"yes\r\"; exp_continue}
				\"*assword:\" {send \"$curr_password\r\"; }
			}
		expect eof;"

	done < $hosts_file

	echo "<<<<<<<<<<<   concurrency=$concurrency  end  <<<<<<<<<<<" >> $log_file
	echo "<<<<<<<<<<<   concurrency=$concurrency  end  <<<<<<<<<<<"
done < conf/concurrency.conf

echo "" >> $log_file
echo "" >> $log_file
echo "" >> $log_file
