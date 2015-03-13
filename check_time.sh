#!/bin/bash
#如果不显示ip地址，将ifconfig&&去掉，用户名和ip地址按照需求更改。
/usr/bin/ssh root@10.10.197.71 ifconfig&&hostname&&date
/usr/bin/ssh root@10.10.197.72 ifconfig&&hostname&&date