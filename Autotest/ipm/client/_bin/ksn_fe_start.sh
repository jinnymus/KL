#!/bin/sh
csn_start()
{
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] log name = '$2 >> ../$2
	echo '[DEBUG] Prepare to start' >> ../$2
fi
ssh $fe_ip_address "/usr/local/etc/rc.d/csn_frontend start"
sleep 30
if [ $debug_status = on ]; then
	echo '[DEBUG] Started' >> ../$2
fi
sleep 3
exec 8>&1 9>&2
exec 1> logfileout_start 2> logfileerror_start
nc -z $fe_ip_address 443
exec 1>&8 2>&9
start=`cat logfileerror_start`
start2=`cat logfileerror_start | cut -f 7 -d " "`
if [ $debug_status = on ]; then
	echo '[DEBUG] start = '$start >> ../$2
	echo '[DEBUG] start2 = '$start2 >> ../$2
fi
if [ "$start2" = "succeeded!" ]; then
	start_status=`echo 'KSN_FE_STARTED'`
fi
}