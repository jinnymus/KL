#!/bin/sh
csn_stop()
{
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] log name = '$2 >> ../$2
	echo '[DEBUG] Prepare to stop' >> ../$2
fi
ssh $fe_ip_address "/usr/local/etc/rc.d/csn_frontend stop"
sleep 30
if [ $debug_status = on ]; then
	echo '[DEBUG] Stopped' >> ../$2
fi
sleep 3
exec 6>&1 7>&2
exec 1> logfileout_stop 2> logfileerror_stop
nc -z $fe_ip_address 443
exec 1>&6 2>&7
stop=`cat logfileerror_stop`
if [ $debug_status = on ]; then
	echo '[DEBUG] stop = "'$stop'"' >> ../$2
fi
if [ "$stop" = "" ]; then
	stop_status=`echo 'KSN_FE_STOPPED'`
fi
}