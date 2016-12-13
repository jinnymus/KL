#!/bin/sh
echo "started controller.finish_monitor.sh"
debug_status=`cat /export/parameters.dat | grep debug_status | cut -f 2 -d =`
monitor_exiting_time=`cat /export/parameters.dat | grep monitor_exiting_time | cut -f 2 -d =`
tests=`cat /export/csn_services_testplan.dat`
running_count=`cat /export/finish.dat | grep -c Running`
time_start=`date +%s`
if [ $debug_status = on ]; then
	echo '[DEBUG] Sending email notification report' >> /export/controller/$1
	echo '[DEBUG] time_start = '$time_start >> /export/controller/$1
	echo '[DEBUG] running_count = '$running_count >> /export/controller/$1 
fi
while [ $running_count -ne 0 ]
do
	running_count=`cat /export/finish.dat | grep -c Running`
	time_end=`date +%s`
	time=`expr $time_end - $time_start`
	echo "Time waiting (controller.finish_monitor) running_count = "$running_count >> /export/controller/$1
	echo "Time waiting (controller.finish_monitor) time_end = "$time_end >> /export/controller/$1
	echo "Time waiting (controller.finish_monitor) time = "$time >> /export/controller/$1		
	if [ $time -gt $monitor_exiting_time ]; then
		echo "Time waiting (controller.finish_monitor) = "$monitor_exiting_time >> /export/controller/$1
		echo "Exiting (controller.finish_monitor)" >> /export/controller/$1
		echo "Time expired (controller.finish_monitor)" >> /export/controller/$1
		break
	fi
	sleep 15
done
echo "All tests finished"
echo "time = "$time 
echo "time_end = "$time_end 
echo "time_start = "$time_start
echo "monitor_exiting_time = "$monitor_exiting_time
 echo "All tests finished" >> /export/controller/$1
./controller.mail_results.sh $1 $2 $3
cat /export/status.dat | sed 's/controller=Running/controller=Stopped/g' > /export/status_new.dat
mv /export/status_new.dat /export/status.dat
