#!/bin/bash

EXPECT_EXIST=0

HOST=""
USER=""
PASSWORD=""
USER_HOME=""

retval=0

# usage
Usage () 
{
	echo "Usage"
	echo "    ssh_without_password.sh -f HOSTS_FILE"
	echo "DESCRIPTION"
	echo "    -f"
	echo "        The path of hosts file. It is a list of \"HOSTNAME(or IP) USER PASSWORD USER_HOME\" you want to trust."
	echo "EXAMPLES"
	echo "    HOSTS_FILE"
	echo "        # /root/ssh_hosts"
	echo "        # The format of this HOSTS_FILE is \"HOSTNAME(or IP) USER PASSWORD USER_HOME\""
	echo "        # For Examples:"
	echo "        40.67.204.101 root R00t2ol2 /root"
	echo "        40.67.204.102 root R00t2ol2 /root"
	echo "        server03 root R00t2ol2 /root"
	echo "    Trust each host listed in /root/ssh_hosts"
	echo "        ssh_without_password.sh -f /root/ssh_hosts"
	echo "Notice"
	echo "    1. Before execute this shell script, you need install \"expect\" command first."
	echo "    2. And make sure @HOSTS_FILE is correct."
	echo "Warning"
	echo "    Since @HOSTS_FILE contains user name & password, this script will delete it for security in the end."
}

# check if user exists
user_exists()
{
	USER="$1"
	user_exist=0
	for USER_INFO in `cat /etc/passwd`
	do
		if [ "${USER_INFO%%:*}" == "$USER" ]
		then
			user_exist=1
			break
		fi
	done
	return $user_exist
}


param_num=$#
if [ $param_num -ne 2 ]
then
	Usage
	exit -1
fi

param_f="$1"
HOSTS_FILE="$2"


if [ "$param_f" != "-f" ]
then
	Usage
	exit -1
fi

if [ ! -e $HOSTS_FILE ]
then
	echo "ERROR: $HOSTS_FILE does not exist"
	exit -1
fi

if [ ! -f $HOSTS_FILE ]
then
	echo "ERROR: $HOSTS_FILE is not a file"
	exit -1
fi



which expect > /dev/null 2>&1
ret=$?
if [ $ret -ne 0 ]
then
#	echo "ERROR : Command \"expect\" not found!"
	EXPECT_EXIST=0
else
	EXPECT_EXIST=1
fi


#echo "********************     generate authorized_keys      ******************"

if [ -e ~/.ssh/id_rsa -a -e ~/.ssh/id_rsa.pub ]
then
	mv ~/.ssh/id_rsa ~/.ssh/id_rsa_bak > /dev/null 2>&1
	mv ~/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub_bak > /dev/null 2>&1
fi

if [ $EXPECT_EXIST -eq 0 ]
then
	ssh-keygen -t rsa
else
	expect -c "
	spawn ssh-keygen -t rsa
		expect {
			\"*id_rsa):\" {send \"\r\"; exp_continue}
			\"*empty for no passphrase):\" {send \"\r\"; exp_continue}
			\"*same passphrase again:\" {send \"\r\"; }
		}
	expect eof;" > /dev/null 2>&1
fi
cp ~/.ssh/id_rsa.pub ~/.ssh/id_rsa .
if [ -e ~/.ssh/id_rsa -a -e ~/.ssh/id_rsa.pub ]
then
	mv ~/.ssh/id_rsa_bak ~/.ssh/id_rsa > /dev/null 2>&1
	mv ~/.ssh/id_rsa.pub_bak ~/.ssh/id_rsa.pub > /dev/null 2>&1
fi

#echo "***************    combine authorized_keys begain:*********************"

touch authorized_keys
touch SUCCESS_LIST
touch FAIL_NETWORK_LIST
touch FAIL_PASSWORD_LIST
> authorized_keys
> SUCCESS_LIST
> FAIL_NETWORK_LIST
> FAIL_PASSWORD_LIST
mkdir .ssh/ >/dev/null 2>&1
touch .ssh/authorized_keys

cat $HOSTS_FILE | while read HOST_INFO
do
	HOST=`echo $HOST_INFO | awk '{print $1}'`
	USER=`echo $HOST_INFO | awk '{print $2}'`
	PASSWORD=`echo $HOST_INFO | awk '{print $3}'`
	USER_HOME=`echo $HOST_INFO | awk '{print $4}'`
	OUTGOING=`ping -c 1 -w 1 $HOST |grep -c ttl`
	if [ $OUTGOING -eq 0 ] 
	then
		echo "Combine authorized_keys of $HOST: Network is unreachable"
		echo $HOST_INFO >> FAIL_NETWORK_LIST
	else
		# if user & password is correct
		> expect.log
		expect -c "
			set timeout 20
			spawn ssh $USER@$HOST \"ps -ef\"
			expect {
				\"*yes/no)?\" {send \"yes\r\"; exp_continue}
				\"*assword:\" {send \"$PASSWORD\r\";}
				}
			expect eof;" > expect.log
		OUPUT_NUM=`cat expect.log | wc -l`
		if [ $OUPUT_NUM -gt 5 ]
		then
			echo $HOST_INFO >> SUCCESS_LIST
			echo "Combine authorized_keys of $HOST: OK"
		else
			echo $HOST_INFO >> FAIL_PASSWORD_LIST
			echo "Combine authorized_keys of $HOST: Username or password is wrong"
		fi

		SSH_RSA_NAME=`cat id_rsa.pub | awk '{print $1}'`
		SSH_RSA_CODE=`cat id_rsa.pub | awk '{print $2}'`
		echo "$SSH_RSA_NAME $SSH_RSA_CODE $USER@$HOST" > id_rsa.pub


		if [ $EXPECT_EXIST -eq 0 ]
		then
			rsync -avzq -R .ssh/authorized_keys $USER@$HOST:$USER_HOME/
		else
			expect -c "
				spawn rsync -avzq -R .ssh/authorized_keys $USER@$HOST:$USER_HOME/ 
				expect {
					\"*yes/no)?\" {send \"yes\r\"; exp_continue}
					\"*assword:\" {send \"$PASSWORD\r\";}
				}
			expect eof;" > /dev/null 2>&1
		fi


		if [ $EXPECT_EXIST -eq 0 ]
		then
			/usr/bin/scp id_rsa.pub id_rsa $USER@$HOST:$USER_HOME/.ssh/
		else
			expect -c "
				spawn /usr/bin/scp id_rsa.pub id_rsa $USER@$HOST:$USER_HOME/.ssh/
				expect {
					\"*yes/no)?\" {send \"yes\r\"; exp_continue}
					\"*assword:\" {send \"$PASSWORD\r\";}
				}
			expect eof;" > /dev/null 2>&1
		fi

		cat id_rsa.pub >> authorized_keys
	fi
done


#echo "***************    combine authorized_keys DONE!*********************"

#echo "********  scp authorized_keys to servers and workstations **********"
#for HOST_INFO in `cat $HOSTS_FILE`
cat SUCCESS_LIST | while read HOST_INFO
do
	HOST=`echo $HOST_INFO | awk '{print $1}'`
	USER=`echo $HOST_INFO | awk '{print $2}'`
	PASSWORD=`echo $HOST_INFO | awk '{print $3}'`
	USER_HOME=`echo $HOST_INFO | awk '{print $4}'`
	OUTGOING=`ping -c1 $HOST |grep -c ttl`
	if [ $OUTGOING -eq 0 ] 
	then
		echo "Copy authorized_keys to $HOST: Network is unreachable"
	else
		echo "Copy authorized_keys to $HOST: OK"
		if [ $EXPECT_EXIST -eq 0 ]
		then
			/usr/bin/scp authorized_keys $USER@$HOST:$USER_HOME/.ssh/
		else
			expect -c "
			spawn /usr/bin/scp authorized_keys $USER@$HOST:$USER_HOME/.ssh/
				expect {
					\"*yes/no)?\" {send \"yes\r\"; exp_continue}
					\"*assword:\" {send \"$PASSWORD\r\";}
				}
			expect eof;" > /dev/null 2>&1
		fi
	fi
done


echo ""
echo "Total `cat SUCCESS_LIST FAIL_NETWORK_LIST FAIL_PASSWORD_LIST | wc -l` hosts."
echo -e "\033[;32m`cat SUCCESS_LIST | wc -l` hosts SUCCESS:\\033[0m"
cat SUCCESS_LIST | while read HOST_INFO
do
	HOST=`echo $HOST_INFO | awk '{print $1,$2}'`
	echo "    $HOST"
done
echo -e "\033[;31m`cat FAIL_NETWORK_LIST FAIL_PASSWORD_LIST | wc -l` hosts FAILED:\\033[0m"
echo "    `cat FAIL_NETWORK_LIST | wc -l` failed because network is unreachable:"
cat FAIL_NETWORK_LIST | while read HOST_INFO
do
	HOST=`echo $HOST_INFO | awk '{print $1,$2}'`
	echo "        $HOST"
done
echo "    `cat FAIL_PASSWORD_LIST | wc -l` failed because user or password is wrong:"
cat FAIL_PASSWORD_LIST | while read HOST_INFO
do
	HOST=`echo $HOST_INFO | awk '{print $1,$2}'`
	echo "        $HOST"
done

# clean temp files
rm -f authorized_keys id_rsa id_rsa.pub $HOSTS_FILE SUCCESS_LIST FAIL_NETWORK_LIST FAIL_PASSWORD_LIST expect.log
