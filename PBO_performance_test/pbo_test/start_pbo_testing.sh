#!/bin/sh

current_date=`date +%Y%m%d%H%M%S`
log_file="logs/pbo_test_${current_date}.log"


echo "" >> $log_file
echo "Begin to clean files" >> $log_file
bash ./clean_files.sh
echo "" >> $log_file
echo "" >> $log_file
date >> $log_file
echo "Clean files DONE" >> $log_file


echo "" >> $log_file
echo "Begin to modify target host" >> $log_file
bash ./modify_target_host.sh
echo "Modify target host DONE" >> $log_file

cp -rf ../apache-jmeter-2.9/ ~

# test channels
while read LINE
do
	echo "" >> $log_file
	echo "Begin to test $LINE" >> $log_file
	bash ./test_${LINE}.sh
	echo "Test $LINE DONE" >> $log_file
done < conf/channel.conf


echo "" >> $log_file
echo "Begin to copy remote results" >> $log_file
bash ./copy_results.sh
echo "Copy remote results DONE" >> $log_file


echo "" >> $log_file
echo "Begin to remove result files to results dir" >> $log_file
mkdir -p results/${current_date}
mkdir -p results/${current_date}/jtl
mkdir -p results/${current_date}/nmon
mv jmeter_*jtl results/${current_date}/jtl

hosts_file="conf/hosts.conf"
while read LINE
do
	curr_host=`echo $LINE | awk '{print $1}'`
	mv ${curr_host}* results/${current_date}/nmon
done < $hosts_file


echo "Remove result files to results dir DONE">> $log_file


echo "" >> $log_file
echo "Parsing jmeter results" >> $log_file
./parse_jtl.sh results/${current_date}/jtl results/${current_date}/jmeter_result_${current_date}.txt
echo "Parsing jmeter results DONE" >> $log_file

echo "" >> $log_file
echo "Get remote memory rate" >> $log_file
./get_remote_server_memory.sh
echo "Get remote memory rate DONE" >> $log_file

echo "" >> $log_file
echo "Parsing nmon results" >> $log_file
./parse_nmon.sh results/${current_date}/nmon results/${current_date}/nmon_result_${current_date}.txt
echo "Parsing nmon results DONE" >> $log_file

echo "ALL DONE" >> $log_file
echo "" >> $log_file
