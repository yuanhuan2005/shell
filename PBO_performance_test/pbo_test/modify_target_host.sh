#!/bin/bash

target_host=`cat conf/target_host.conf | head -n 1 | awk '{print $1}'`
target_port=`cat conf/target_host.conf | head -n 1 | awk '{print $2}'`

cp -rf jmeter/* .
sed -i "s/TEST_TARGET_HOST/$target_host/g" *.jmx
sed -i "s/TEST_TARGET_PORT/$target_port/g" *.jmx

