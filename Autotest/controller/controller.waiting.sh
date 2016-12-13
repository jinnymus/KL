#!/bin/sh
echo "started controller.waiting.sh"
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
running_count=`cat ../finish.dat | grep -c Running`
monitor_exiting_time=`cat ../parameters.dat | grep monitor_exiting_time | cut -f 2 -d =`
controller_esx_ip=`cat ../parameters.dat | grep controller_esx_ip | cut -f 2 -d =`
vmstop=`cat ../parameters.dat | grep vmstop | cut -f 2 -d =`
time_start=`date +%s`
if [ $debug_status = on ]; then
	echo "[DEBUG] start while loop" >> $1
fi
while [ $running_count -ne 0 ]
do
	running_count=`cat ../finish.dat | grep -c Running`
	time_end=`date +%s`
	time=`expr $time_end - $time_start`
	datetime=`date +%d.%m.%y_%T`
	echo "Waiting finish testing...(controller.waiting.sh).."$datetime
	if [ $debug_status = on ]; then
		echo "[DEBUG] Waiting finish testing...(controller.waiting.sh).."$datetime >> $1
	fi
	if [ $time -gt $monitor_exiting_time ]; then
		if [ $debug_status = on ]; then
			echo "[DEBUG] Time waiting (controller.waiting)= "$monitor_exiting_time >> $1
			echo "[DEBUG] Exiting (controller.waiting)" >> $1
			echo "[DEBUG] Time expired (controller.waiting)" >> $1
		fi
		echo "Time waiting (controller.waiting) = "$monitor_exiting_time
		echo "Exiting (controller.waiting)"
		echo "Time expired (controller.waiting)"
		break
	fi
	if [ $debug_status = on ]; then
		echo "[DEBUG] Sleeping 300" >> $1
	fi
	sleep 300
done
if [ $vmstop = yes ]; then
	if [ $debug_status = on ]; then
		echo "[DEBUG] start vm stop" >> $1
	fi
	ssh $controller_esx_ip "/export/controller/controller.esx_stop.sh "$1
	if [ $debug_status = on ]; then
		echo "[DEBUG] end vm stop" >> $1
	fi
fi
echo "______________"
echo "ipm status.dat"
echo "______________"
cat /export/ipm/status.dat
echo "______________"
echo "url status.dat"
echo "______________"
cat /export/url/status.dat
echo "______________"
echo "finish.dat"
echo "______________"
cat /export/finish.dat
#rm -rf /usr/local/www/data/results/*
#cp -rf /export/results/* /usr/local/www/data/results
ipm_status_fail=`cat /export/ipm/status.dat | grep -c Fail`
ipm_status_running=`cat /export/ipm/status.dat | grep -c Running`
url_status_fail=`cat /export/url/status.dat | grep -c Fail`
url_status_running=`cat /export/url/status.dat | grep -c Running`
if [ $ipm_status_fail -gt 0 ]; then
	test_status="100"
elif [ $ipm_status_running -gt 0 ]; then
	test_status="200"
elif [ $url_status_fail -gt 0 ]; then
	test_status="300"
elif [ $url_status_running -gt 0 ]; then
	test_status="400"
else
	test_status="0"
fi
endtestdatetime=`date +%d.%m.%y_%T`
echo "End "$endtestdatetime
echo "autotests_code="$test_status
exit $test_status