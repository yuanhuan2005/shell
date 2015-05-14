#!/bin/bash

default_port=32200
curr_dir=`dirname $0`
template_file="${curr_dir}/template.xsh"

if [ $# -ne 2 ]
then
    echo "Usage: $0 SecureCRT_Sessions_Dir Outputs_Dir"
    echo "    SecureCRT_Sessions_Dir: directory path of SecureCRT sessions"
    echo "    Outputs_Dir: directory of results"
    exit 1
fi

secrt_sessions_dir="$1"
results_dir="$2"
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

ls -1 ${secrt_sessions_dir} | while read LINE
do
    if [ "`echo ${LINE%%__*}`X" == "X" ]
    then
        continue
    fi

    secrt_file=${secrt_sessions_dir}/${LINE}
    which dos2unix > /dev/null 2>&1
    if [ $? -eq 0 ]
    then
        dos2unix ${secrt_file} > /dev/null 2>&1
    fi

    hostname=`echo ${LINE%.*}`
    user=`cat ${secrt_file} | grep "S:\"Username\"" | awk -F= '{print $2}'`
    host=`cat ${secrt_file} | grep Hostname | awk -F= '{print $2}'`
    port_16=`cat ${secrt_file} | grep "\[SSH2\] Port" | awk -F= '{print $2}'`
    ((port=16#${port_16}))
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
        echo "successfully generate ${xsh_file} | ${user}@${host}:${port}"
    else
        echo "failed to generate ${xsh_file}"
    fi
done




