#!/bin/sh

if [ $# -ne 2 ]
then
	echo "Usage: $0 input_JTL_DIR output_RESULT_FILE"
	exit 1
fi



jtl_dir="$1"
result_file="$2"
date > $result_file


if [ ! -e $jtl_dir ]
then
	echo "Error : $jtl_dir does not exist"
	exit 1
fi

if [ ! -d $jtl_dir ]
then
	echo "Error : $jtl_dir is not a dir"
	exit 1
fi

if [ ! -f $result_file ]
then
	echo "Error : $result_file can not be generated"
	exit 1
fi

ls -1 $jtl_dir | while read LINE
do
	jtl_file="$jtl_dir/$LINE"
	total_num=`cat $jtl_file | wc -l`
	echo "" >> $result_file
	echo "jtl_file=$jtl_file" >> $result_file

	# concurrency
	base_name="${LINE%.*}"
	concurrency="${base_name##*_}" 
	echo "Concurrency : $concurrency" >> $result_file

	# Samples
	echo "#Samples Total Number : `cat $jtl_file | wc -l`" >> $result_file

	# Total time
	begin_time=`awk -F ',' '{print $1}' $jtl_file | sort -n | head -n 1`
	end_time=`awk -F ',' '{print $1}' $jtl_file | sort -n | tail -n 1`
	between_time=`expr $end_time - $begin_time`
	awk -v begin_time=$begin_time -v end_time=$end_time 'END {print "Total Time : ", (end_time-begin_time)/1000}' $jtl_file >> $result_file

	# Error Number
	awk -F ',' 'BEGIN{sum=0} {if($4!=200) sum+=1} END {print "Error Number : ", sum}' $jtl_file >> $result_file
	
	# Error%
	awk -F ',' 'BEGIN{sum=0} {if($4!=200) sum+=1} END {print "Error% : ", sum/NR*100,"%"}' $jtl_file >> $result_file


	# Total transferred
	awk -F ',' 'BEGIN{sum=0} {sum+=$(NF-1)} END {print "Total transferred : ", sum}' $jtl_file >> $result_file

	# Throughput
	tmp_file=`mktemp`
	awk -F ',' '{print $1}' $jtl_file | sort -n > $tmp_file
	begin_time=`cat $tmp_file | head -n 1`
	end_time=`cat $tmp_file | tail -n 1`
	between_time=`expr $end_time - $begin_time`
	throughput=`awk -v between_time=$between_time 'END{print NR/between_time*1000}' $tmp_file`
	rm -f $tmp_file
	echo "Throughput : $throughput" >> $result_file

	# Time per requests
	time_per_user_req=`awk -F ',' 'BEGIN{sum=0} {sum+=$2} END {print sum/NR}' $jtl_file`
	echo "Time per requests : $time_per_user_req" >> $result_file

	# Median
	median_num=0
	tmp_file=`mktemp`
	awk -F ',' '{print $2}' $jtl_file | sort -n > $tmp_file
	left_num=`expr $total_num % 2`
	half=`expr $total_num / 2`
	if [ $left_num -eq 1 ]
	then
		i=1
		while read LINE
		do
			if [ $i -eq $half ]
			then
				median_num=$LINE
				break
			fi

			i=`expr $i + 1`
		done < $tmp_file
	else
		i=1
		half_1=$half
		half_2=`expr $half_1 + 1`
		while read LINE
		do
			if [ $i -eq $half_1 ]
			then
				median_num_1=$LINE
			fi
			if [ $i -eq $half_2 ]
			then
				median_num_2=$LINE
				break
			fi

			i=`expr $i + 1`
		done < $tmp_file
		median_num=`expr $median_num_1 + $median_num_2`
		median_num=`expr $median_num / 2`
	fi
	rm -f $tmp_file
	echo "Median : $median_num" >> $result_file

	# 90% Line
	ninety_line_num=0
	tmp_file=`mktemp`
	awk -F ',' '{print $2}' $jtl_file | sort -n > $tmp_file
	ninety_percent="0.9"
	awk -F ',' '{print $2}' $jtl_file | sort -n> $tmp_file
	ninety_line=`awk -v ninety_percent=$ninety_percent 'END{print ninety_percent*NR}' $tmp_file`
	ninety_line=`echo $ninety_line | sed 's/\./ /g' | awk '{print $1}'`
	i=1
	while read LINE
	do
		if [ $i -eq $ninety_line ]
		then
			ninety_line_num=$LINE
			break
		fi

		i=`expr $i + 1`
	done < $tmp_file
	rm -f $tmp_file
	echo "90% Line : $ninety_line_num" >> $result_file
	
	# Min
	min_req_time=`awk -F ',' '{print $2}' $jtl_file | sort -n | head -n 1`
	echo "Min : $min_req_time" >> $result_file
	
	# Max
	max_req_time=`awk -F ',' '{print $2}' $jtl_file | sort -n | tail -n 1`
	echo "Max : $max_req_time" >> $result_file

	# Time per requests : accross all concurrency
	base_name="${LINE%.*}"
	concurrency="${base_name##*_}" 
	time_per_concurrency_req=`echo "" | awk -v concurrency=$concurrency -v time_per_user_req=$time_per_user_req 'END{print time_per_user_req/concurrency}'`
	echo "Time per requests (accross all concurrency) : $time_per_concurrency_req" >> $result_file

	# KB/Sec
	tmp_file=`mktemp`
	awk -F ',' '{print $(NF-1)}' $jtl_file > $tmp_file
	bytes_sum=`awk -F ',' 'BEGIN{sum=0} {sum+=$(NF-1)} END {print sum}' $jtl_file`
	KBPS=`awk -v between_time=$between_time -v bytes_sum=$bytes_sum 'END{print bytes_sum/between_time*1000/1024}' $tmp_file`
	echo "KB/Sec : $KBPS" >> $result_file

done

