#!/bin/bash

/usr/sbin/ntpdate ccs-net1 &> /dev/null || /usr/sbin/ntpdate ccs-net2 &> /dev/null
