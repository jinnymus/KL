#!/bin/sh
print_log()
{
	testdatetime=`date +%d.%m.%y_%T`
	echo $testdatetime" [ DEBUG ] "$1
}
csn_start()
{
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat ../parameters.dat | grep fe_ip_address | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] log name = '$2 >> ../$2
	echo '[DEBUG] log fe_ip_address = '$fe_ip_address >> ../$2
	echo '[DEBUG] Prepare to start' >> ../$2
fi
#exec 6>&1 7>&2
rm -rf logfileout_starting
#rm -rf logfileerror_starting
rm -rf logfileout_start
#rm -rf logfileerror_start
#exec 1> logfileout_starting 2> logfileerror_starting
print_log "start start" >> ../$2
starting=`/usr/local/etc/rc.d/csn_frontend start 2>&1`
print_log "start end" >> ../$2
start1=`nc -z 10.65.66.4 443 2>&1`
#exec 1>&6 2>&7
if [ $debug_status = on ]; then
	echo '[DEBUG] sleep 15 sec' >> ../$2
	#sleep 30
	#starting1=`cat logfileerror_starting`
	#starting2=`cat logfileout_starting`	
	echo $starting > logfileout_starting
	echo '[DEBUG] starting 1 = "'$starting'"' >> ../$2
	#echo '[DEBUG] starting 1 = "'$starting1'"' >> ../$2
	#echo '[DEBUG] starting 2 = "'$starting2'"' >> ../$2
	echo '[DEBUG] Started' >> ../$2
fi
#sleep 3
#exec 8>&1 9>&2
#exec 1> logfileout_start 2> logfileerror_start
print_log "check start" >> ../$2
#start=`nc -z $fe_ip_address 443 2>&1`
start=`nc -z 10.65.66.4 443 2>&1`

print_log "check end" >> ../$2
#exec 1>&8 2>&9
#start=`cat logfileerror_start`
#start2=`cat logfileerror_start | cut -f 7 -d " "`
start2=`echo $start | cut -f 7 -d " "`
echo $start > logfileout_start

if [ $debug_status = on ]; then
	echo '[DEBUG] start = '$start >> ../$2
	echo '[DEBUG] start1 = '$start1 >> ../$2
	echo '[DEBUG] start2 = '$start2 >> ../$2
fi
if [ "$start2" = "succeeded!" ]; then
	start_status=`echo 'KSN_FE_STARTED'`
fi
}