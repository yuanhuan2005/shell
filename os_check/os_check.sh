#!/bin/bash

curr_dir=`dirname $0`
sub_checks_dir="${curr_dir}/check.d"

ls -1 $sub_checks_dir | while read LINE
do
	/bin/bash ${sub_checks_dir}/$LINE -i
	/bin/bash ${sub_checks_dir}/$LINE
	echo ""
	echo ""
done
