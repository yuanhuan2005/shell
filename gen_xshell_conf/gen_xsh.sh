#!/bin/bash

default_port=32200
curr_dir=`dirname $0`
template_file="${curr_dir}/template.xsh"

if [ $# -ne 2 ]
then
    echo "Usage: $0 HOST_FILE RESULTS_DIR"
    echo "    HOST_FILE: host file path"
    echo "        format 1: \"HOSTNAME###{USER}@{HOST}:{PORT}\", example: \"test_server_01###testuser@10.10.10.10:22\""
    echo "        format 2: \"HOSTNAME###{USER}@{HOST}\", example: \"test_server_01###testuser@10.10.10.10\", default port: ${default_port}"
    exit 1
fi

host_file=$1
results_dir=$2
if [ ! -e ${results_dir} ]
then
    read -p "${results_dir} not found, do you want to create it: [y|n]: " if_create_results_dir
    if [ ${if_create_results_dir}X != "yX" ]
    then
        echo "nothing to do, exiting..."
        exit 1
    fi

    mkdir -p ${results_dir}
    if [ $? -ne 0 ]
    then
        echo "failed to create ${results_dir}"
        exit 1
    fi
fi

cat ${host_file} | while read LINE
#for LINE in `cat ${host_file}`
do
    if [ `echo $LINE | grep -c "###"` -ne 1 ]
    then
        continue
    fi

    hostname=`echo $LINE | awk -F "###" '{print $1}'`
    user=`echo $LINE | awk -F "###" '{print $2}' | awk -F "@" '{print $1}'`
    host=`echo $LINE | awk -F "###" '{print $2}' | awk -F "@" '{print $2}' | awk -F ":" '{print $1}'`
    port=`echo $LINE | awk -F "###" '{print $2}' | awk -F "@" '{print $2}' | awk -F ":" '{print $2}'`
    if [ ${port}X == "X" ]
    then
        port=${default_port}
    fi

    xsh_file="${results_dir}/${hostname}.xsh"
#    if [ -e ${xsh_file} ]
#    then
#        read -p "${xsh_file} exists, do you want to overwrite it: [y|n]: " if_overwrite
#        if [ ${if_overwrite}X != "yX" ]
#        then
#            echo "${xsh_file} exists, skip it..."
#            continue
#        fi
#    fi

    cp -f ${template_file} ${xsh_file} && sed -i "s/SERVER_HOSTNAME/${host}/g" ${xsh_file} && sed -i "s/USERNAME/${user}/g" ${xsh_file} && sed -i "s/PORT/${port}/g" ${xsh_file}
    if [ $? -eq 0 ]
    then
        echo "successfully generate ${xsh_file}"
    else
        echo "failed to generate ${xsh_file}"
    fi
done




