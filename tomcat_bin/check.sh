#!/bin/bash

curr_dir=`dirname $0`


tomcat_config=${curr_dir}/tomcat.config

if [ ! -e "$tomcat_config" ]
then
	exit 1
fi

if [ ! -f "$tomcat_config" ]
then
	exit 1
fi

running_user=`cat ${tomcat_config} | grep "running_user" | awk -F= '{print $2}'`
if [ `cat /etc/passwd | awk -F: '{print $1 ":"}' | grep "${running_user}:" | wc -l` -eq 0 ]
then
	exit 1
fi

tomcat_home=`cat ${tomcat_config} | grep "tomcat_home" | awk -F= '{print $2}'`
if [ ! -d ${tomcat_home} ]
then
	exit 1
fi

exit 0
