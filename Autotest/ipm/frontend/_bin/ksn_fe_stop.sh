#!/bin/sh
print_log()
{
	testdatetime=`date +%d.%m.%y_%T`
	echo $testdatetime" [ DEBUG ] "$1
}
csn_stop()
{
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat ../parameters.dat | grep fe_ip_address | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] log name = '$2 >> ../$2
	echo '[DEBUG] log fe_ip_address = '$fe_ip_address >> ../$2
	echo '[DEBUG] Prepare to stop' >> ../$2
fi
print_log "rm files" >> ../$2
rm -rf logfileout_stopping
#rm -rf logfileerror_stopping
rm -rf logfileout_stop
#rm -rf logfileerror_stop
#exec 6>&1 7>&2
#exec 1> logfileout_stopping 2> logfileerror_stopping
print_log "stop start" >> ../$2
stopping=`/usr/local/etc/rc.d/csn_frontend stop 2&>1`
print_log "stop end" >> ../$2
stop1=`nc -z 10.65.66.4 443 2>&1`
exec 1>&6 2>&7
if [ $debug_status = on ]; then
	echo '[DEBUG] sleep 15 sec' >> ../$2
	#sleep 30
	#stopping1=`cat logfileerror_stopping`
	#stopping2=`cat logfileout_stopping`	
	echo $stopping > logfileout_stopping
	echo '[DEBUG] stopping 1 = "'$stopping'"' >> ../$2
	#echo '[DEBUG] stopping 1 = "'$stopping1'"' >> ../$2
	#echo '[DEBUG] stopping 2 = "'$stopping2'"' >> ../$2
	echo '[DEBUG] Stopped' >> ../$2
fi
#sleep 3
#exec 6>&1 7>&2
#exec 1> logfileout_stop 2> logfileerror_stop
print_log "check start" >> ../$2
#stop=`nc -z $fe_ip_address 443 2>&1`
stop=`nc -z 10.65.66.4 443 2>&1`

print_log "check end" >> ../$2
#exec 1>&6 2>&7
#stop=`cat logfileerror_stop`
echo $stop > logfileout_stop
	
if [ $debug_status = on ]; then
	#echo '[DEBUG] stop = "'$stop'"' >> ../$2
	#stop1=`cat logfileerror_stop`
	#stop2=`cat logfileout_stop`	
	echo '[DEBUG] stop 1 = "'$stop'"' >> ../$2
	echo '[DEBUG] stop1 1 = "'$stop1'"' >> ../$2
	#echo '[DEBUG] stop 1 = "'$stop1'"' >> ../$2
	#echo '[DEBUG] stop 2 = "'$stop2'"' >> ../$2
	echo '[DEBUG] Stopped' >> ../$2	
fi
if [ "$stop" = "" ]; then
	stop_status=`echo 'KSN_FE_STOPPED'`
fi
}