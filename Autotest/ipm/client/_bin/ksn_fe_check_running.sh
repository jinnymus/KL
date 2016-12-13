#!/bin/sh
csn_check()
{
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] Prepare to check' >> ../$2
fi
exec 4>&1 5>&2
exec 1> logfileout_check 2> logfileerror_check
nc -z $fe_ip_address 443
exec 1>&4 2>&5
if [ $debug_status = on ]; then
	echo '[DEBUG] Checked' >> ../$2
fi
running=`cat logfileerror_check`
running2=`cat logfileerror_check | cut -f 7 -d " "`
if [ $debug_status = on ]; then
	echo '[DEBUG] running = '$running2 >> ../$2
fi
if [ "$running2" = "succeeded!" ]; then
	running_status=`echo 'KSN_FE_RUNNING'`
fi
}