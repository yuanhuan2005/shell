#!/bin/sh

if [ $# -ne 2 ]
then
	echo "Usage : $0 input_nmon_dir output_result_file"
	exit 1
fi

hosts_file="conf/hosts.conf"
input_nmon_dir="$1"
output_result_file="$2"
server_memory="server_memory"
tmp_output_result_file=`mktemp`
> $tmp_output_result_file
> $output_result_file


if [ ! -e $input_nmon_dir ]
then
	echo "$input_nmon_dir not found"
	exit 1
fi

if [ ! -d $input_nmon_dir ]
then
	echo "$input_nmon_dir not a dir"
	exit 1
fi

find $input_nmon_dir -type f | while read LINE
do
    nmon_file="$LINE"
    output_result_line=`basename $nmon_file`
    output_result_line=${output_result_line%.*}


    # CPU
    cpu_rate=`cat $nmon_file |grep CPU_ALL |grep -v "CPU Total" | awk -F ',' '{sum+=$3} END{print sum/NR , "%"}'`
    output_result_line="${output_result_line},${cpu_rate}"

    # Memory
    mem_rate=`cat $nmon_file | grep "MEM" |grep -v "Memory MB" | awk -F ',' '{total_mem+=$3;memfree+=$7;cached+=$12;buffers+=$15} END{print (total_mem-memfree-cached-buffers)/total_mem*100,"%"}'`
    output_result_line="${output_result_line},${mem_rate}"

    # NET read KB/s
    net_read_rate=`cat $nmon_file |grep "NET," |grep -v "Network I" | awk -F ',' '{sum+=$5} END{print sum/NR, "KB/s"}'`
    output_result_line="${output_result_line},${net_read_rate}"

    # NET write KB/s
    net_write_rate=`cat $nmon_file |grep "NET," |grep -v "Network I" | awk -F ',' '{sum+=$10} END{print sum/NR, "KB/s"}'`
    output_result_line="${output_result_line},${net_write_rate}"

    # Write to tmp output file
    echo "$output_result_line" >> $tmp_output_result_file
done



# format results
echo "Channel_Concurrency,CPU rate,MEM rate,NET read rate,NET write rate" >> $output_result_file
while read CHANNEL
do
	while read CONCURRENCY
	do
		output_result_line="${CHANNEL}_${CONCURRENCY}"

		tmp_file=`mktemp`
		cat $tmp_output_result_file |grep $CHANNEL | grep $CONCURRENCY > $tmp_file

		# CPU
		while read LINE
		do
			curr_host=`echo $LINE | awk '{print $1}'`
			curr_username=`echo $LINE | awk '{print $2}'`
			curr_password=`echo $LINE | awk '{print $3}'`
			cpu_rate=`cat $tmp_file |grep "${curr_host}" | awk -F ',' '{print $2}'`
	        output_result_line="${output_result_line};${curr_username}@${curr_host} cpu rate : ${cpu_rate}"
		done < $hosts_file

		
		# MEM
		while read LINE
		do
			curr_host=`echo $LINE | awk '{print $1}'`
			curr_username=`echo $LINE | awk '{print $2}'`
			curr_password=`echo $LINE | awk '{print $3}'`
			load_mem=`cat $tmp_file |grep "${curr_host}" | awk -F ',' '{print $3}' | awk '{print $1}'`
			not_load_mem=`cat $server_memory |grep "${curr_host}" | awk '{print $2}'`
			mem_rate=`echo "" | awk -v load_mem=$load_mem -v not_load_mem=$not_load_mem 'END {print load_mem - not_load_mem}'`
			output_result_line="${output_result_line};${curr_username}@${curr_host} mem_rate: ${mem_rate}%"
		done < $hosts_file


		# NET read
		while read LINE
		do
			curr_host=`echo $LINE | awk '{print $1}'`
			curr_username=`echo $LINE | awk '{print $2}'`
			curr_password=`echo $LINE | awk '{print $3}'`
			net_write=`cat $tmp_file |grep "$curr_host" | awk -F ',' '{print $4}'`
			output_result_line="${output_result_line}; ${curr_username}@${curr_host} net_read: ${net_write}"
		done < $hosts_file

		# NET write
		while read LINE
		do
			curr_host=`echo $LINE | awk '{print $1}'`
			curr_username=`echo $LINE | awk '{print $2}'`
			curr_password=`echo $LINE | awk '{print $3}'`
			net_write=`cat $tmp_file |grep "$curr_host" | awk -F ',' '{print $5}'`
			output_result_line="${output_result_line}; ${curr_username}@${curr_host} net_write: ${net_write}"
		done < $hosts_file


		echo "$output_result_line" >> $output_result_file
	done < conf/concurrency.conf
done < conf/channel.conf


rm -f $tmp_output_result_file $tmp_file
