#!/bin/bash

MEM_LOG_PATH=/var/log/system.log

# Do some copies if $MEM_LOG_PATH is bigger than max_size 
max_size=31457280 # 30M

if [ -e $MEM_LOG_PATH ]
then
	size=`ls -l $MEM_LOG_PATH |awk '{print $5}' |awk 'END{print}'`
	if [ $size -gt $max_size ]
	then
		if [ -e $MEM_LOG_PATH.3 ]
		then
	                cp -f $MEM_LOG_PATH.3 $MEM_LOG_PATH.4
		        cp -f $MEM_LOG_PATH.2 $MEM_LOG_PATH.3
	        	cp -f $MEM_LOG_PATH.1 $MEM_LOG_PATH.2
		elif [ -e $MEM_LOG_PATH.2 ]
		then
			cp -f $MEM_LOG_PATH.2 $MEM_LOG_PATH.3
			cp -f $MEM_LOG_PATH.1 $MEM_LOG_PATH.2
		elif [ -e $MEM_LOG_PATH.1 ]
		then
			cp -f $MEM_LOG_PATH.1 $MEM_LOG_PATH.2
		fi

		mv -f $MEM_LOG_PATH $MEM_LOG_PATH.1
		touch $MEM_LOG_PATH
	fi
fi

# Beginning to record memory infomations in file: $MEM_LOG_PATH

#Record date in file: $MEM_LOG_PATH
echo "MEMORY LOG BEGINNING: "`date`":" >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

# Record `free -m` in file: $MEM_LOG_PATH
echo "free -m :" >> $MEM_LOG_PATH
free -m >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

# Record /proc/meminfo in file: $MEM_LOG_PATH
echo "cat /proc/meminfo :" >> $MEM_LOG_PATH
cat /proc/meminfo >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

# Record /proc/loadavg in file: $MEM_LOG_PATH
loadavg=`echo "cat /proc/loadavg :"`
echo $loadavg >> $MEM_LOG_PATH
cat /proc/loadavg >> $MEM_LOG_PATH
echo "first  value : average number of processes in last 1 minates" >> $MEM_LOG_PATH
echo "second value : average number of processes in last 5 minates" >> $MEM_LOG_PATH
echo "third  value : average number of processes in last 15 minates" >> $MEM_LOG_PATH
echo "fouth  value : number of running processes/processes total" >> $MEM_LOG_PATH
echo "fifth  value : latest process ID" >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

#Record `vmstat $second $count` in file: $MEM_LOG_PATH
second=2
count=3
echo "vmstat $second $count : update in $second seconds and $count times" >> $MEM_LOG_PATH
vmstat $second $count >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

# Record `ps aux`(%CPU > 0.0) in file: $MEM_LOG_PATH
echo "ps aux (%CPU > 0.0) :" >> $MEM_LOG_PATH
ps aux | awk '{if ($3 > 0.0) print $0}' >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH

# Record `ps aux`(%MEM > 0.0) in file: $MEM_LOG_PATH
echo "ps aux (%MEM > 0.0) :" >> $MEM_LOG_PATH
ps aux | awk '{if ($4 > 0.0) print $0}' >> $MEM_LOG_PATH
echo "******************  THE END *****************" >> $MEM_LOG_PATH
echo "" >> $MEM_LOG_PATH
exit
