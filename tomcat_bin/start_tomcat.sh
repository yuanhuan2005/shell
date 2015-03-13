#!/bin/bash


curr_dir=`dirname $0`
${curr_dir}/check.sh
if [ $? -ne 0 ]
then
	echo "ERROR: Failed to check environment of tomcat."
	echo "Please check tomcat.config"
	exit 1
fi

tomcat_config=${curr_dir}/tomcat.config
running_user=`cat ${tomcat_config} | grep "running_user" | awk -F= '{print $2}'`
tomcat_home=`cat ${tomcat_config} | grep "tomcat_home" | awk -F= '{print $2}'`

tomcat_pid=`ps -ef |grep -v grep | grep ${running_user} | grep tomcat |grep java | head -n 1 |awk '{print $2}'`
if [ "${tomcat_pid}x" != "x" ]
then
	echo "tomcat is already running"
	exit 0
fi

curr_user=`whoami`
if [ "$curr_user" == "${running_user}" ]
then
        ${tomcat_home}/bin/startup.sh > /dev/null 2>&1
else
        su ${running_user} -c ${tomcat_home}/bin/startup.sh > /dev/null 2>&1
fi

if [ $? -eq 0 ]
then
	echo "tomcat is running"
else
	echo "faield to start tomcat"
fi

