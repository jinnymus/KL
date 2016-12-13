#!/bin/sh
hosts=`cat $1`
for host in $hosts
do
	#echo $host
	ip=`host $host | cut -f 4 -d " "`
	#echo $ip
	if [ $2 = $ip ]; then
		search_host=`echo $host`
		echo $host
	fi
done
