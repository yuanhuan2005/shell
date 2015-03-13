#!/usr/bin/expect -f
#auto ssh login
set timeout 5
spawn ssh root@40.10.1.4
expect ¡°assword:¡±
send ¡°root\r¡±
interact 
echo
date
