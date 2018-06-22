#!/usr/bin/env bash
#
# Daizu v1.0.0
# IP address informing tool for some Japanese common DDNS services.
# Copyright (c) 2018 Ryo Nakano
# Released under MIT License, see LICENSE.txt
#
#
#
cd `dirname $0`
mkdir -p ./log
touch ./log/daizu.log
echo -e "=================================" >> ./log/daizu.log && date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Started Daizu." >> ./log/daizu.log
#
echo -e "\n=================================\nDaizu v0.01\n"
echo -e "Choose DDNS service you want to inform.\n 1. MyDNS.JP\n 2. ieServer\n"
while true; do
	read -p "Choose 1-2: " SERVICE
	case $SERVICE in
    	[12] ) break;;
        * ) echo "Choose from 1 to 2.";;
	esac
done
if [ $SERVICE = 1 ]; then
	SERVICE=MyDNS.JP # Use for displaying
	SERVICEID=mydns # Use for file name
	echo -e -n "$SERVICE was chosen.\nNext, type your UserID.\nUserID: "
	read USERID
	echo -e -n "Type your password.\nPassWord: "
	read PASSWORD
	wget -O - --http-user=$USERID --http-password=$PASSWORD http://www.mydns.jp/login.html
	if [ $? = 0 ]; then
		date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Succeeded: Informing to $USERID ($SERVICE)" | tee -a ./log/daizu.log
		cp ./ip_update.sh ./$SERVICEID\_$USERID\_update.sh
		echo -e "wget -O - --http-user=$USERID --http-password=$PASSWORD https://www.mydns.jp/login.html\nif [ \$? = 0 ]; then\ndate | tr '\\\n' ' ' >> ./log/daizu.log && echo -e \"Succeeded: Informing to $USERID ($SERVICE)\" | tee -a ./log/daizu.log\nelse\ndate | tr '\\\n' ' ' >> ./log/daizu.log && echo -e \"Failed: Informing to $USERID ($SERVICE)\" | tee -a ./log/daizu.log\nfi" >> ./$SERVICEID\_$USERID\_update.sh
		chmod 700 ./$SERVICEID\_$USERID\_update.sh
		echo -e "To inform regularly, execute \"crontab -e\" and add, for example,\n10,40 1-23/3 * * * $(pwd)/$SERVICEID\_$USERID\_update.sh"
	else
		date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Failed: Informing to $USERID ($SERVICE)" | tee -a ./log/daizu.log
		echo -e "UserID or password you typed may be wrong. Re-execute Daizu and try again."
		rm -f ./$SERVICEID\_$USERID\_update.sh
	fi
elif [ $SERVICE = 2 ]; then
	SERVICE=ieServer # Use for displaying
	SERVICEID=ieserver # Use for file name
	echo -e -n "$SERVICE was chosen.\nNext, type your account name.\nAccount Name: "
	read ACCOUNT
	echo -e -n "Type your domain name (e.g. dip.jp).\nDomain Name: "
	read DOMAIN
	echo -e -n "Type your password.\nPassWord: "
	read PASSWORD
	wget -O - "http://ieserver.net/cgi-bin/dip.cgi?username=$ACCOUNT&domain=$DOMAIN&password=$PASSWORD&updatehost=1" | iconv -f EUC-JP -t UTF-8 | grep post # Succeed when the word "post" was output
	if [ $? = 0 ]; then
		date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Succeeded: Informing to $ACCOUNT.$DOMAIN ($SERVICE)" | tee -a ./log/daizu.log
		cp ./ip_update.sh ./$SERVICEID\_$ACCOUNT\_update.sh
		echo -e "wget -O - \"http://ieserver.net/cgi-bin/dip.cgi?username=$ACCOUNT&domain=$DOMAIN&password=$PASSWORD&updatehost=1\" | iconv -f EUC-JP -t UTF-8 | grep post\nif [ \$? = 0 ]; then\ndate | tr '\\\n' ' ' >> ./log/daizu.log && echo -e \"Succeeded: Informing to $ACCOUNT.$DOMAIN ($SERVICE)\" | tee -a ./log/daizu.log\nelse\ndate | tr '\\\n' ' ' >> ./log/daizu.log && echo -e \"Failed: Informing to $ACCOUNT.$DOMAIN ($SERVICE)\" | tee -a ./log/daizu.log\nfi" >> ./$SERVICEID\_$ACCOUNT\_update.sh
		chmod 700 ./$SERVICEID\_$ACCOUNT\_update.sh
		echo -e "To inform regularly, execute \"crontab -e\" and add, for example,\n20,50 1-23/3 * * * $(pwd)/$SERVICEID\_$ACCOUNT\_update.sh"
	else
		date | tr '\n' ' ' >> ./log/daizu.log && echo -e "Failed: Informing to $ACCOUNT.$DOMAIN ($SERVICE)" | tee -a ./log/daizu.log
		echo -e "Account name, domain name or password you typed may be wrong. Re-execute Daizu and try again."
		rm -f ./$SERVICEID\_$ACCOUNT\_update.sh
	fi
else
	exit
fi
