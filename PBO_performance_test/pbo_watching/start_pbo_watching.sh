#!/bin/sh

./clean_files.sh
./modify_target_host.sh

cp -rf ../apache-jmeter-2.9 ~
> watch.log

num=1
i=0
while true
do
	echo "******************** `date` begin to watch No.${i}  ****************************" >> watch.log
	> log.jtl
	cp coverId_movie /tmp/userId-coverId.txt
	~/apache-jmeter-2.9/bin/jmeter -n -t PBO_movie.jmx -l log.jtl
	
	> log.jtl
	cp coverId_cartoon /tmp/userId-coverId.txt
	~/apache-jmeter-2.9/bin/jmeter -n -t PBO_cartoon.jmx -l log.jtl
	
	> log.jtl
	cp coverId_tv /tmp/userId-coverId.txt
	~/apache-jmeter-2.9/bin/jmeter -n -t PBO_tv.jmx -l log.jtl
	
	> log.jtl
	cp coverId_variety /tmp/userId-coverId.txt
	~/apache-jmeter-2.9/bin/jmeter -n -t PBO_variety.jmx -l log.jtl

	echo "******************** `date` end to watch No.${i}  ****************************" >> watch.log
	i=`expr $i + 1`
	if [ $i -gt $num ]
	then
		break
	fi

done

echo "******************** `date` ALL DONE  ****************************" >> watch.log
