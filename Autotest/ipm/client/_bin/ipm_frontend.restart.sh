#!/bin/sh
run_restart() {
. ./csn_fe_check_running.sh
. ./csn_fe_stop.sh
. ./csn_fe_start.sh
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
running_status=0
stop_status=0
start_status=0
check_fail=0
restart_pass=0
echo 'DEBUG = '$debug_status
if [ $debug_status = on ]; then
	echo '[DEBUG] Prepare to running'
	echo '[DEBUG] Prepare to running' >> ../$1
fi
#csn_check $running_status $1
running_status=`/export/ipm/client/_bin/ipm_client.nc.pl "/export/ipm/frontend" "/export/ipm/client/$1"`
#if [ "$running_status" = "KSN_FE_RUNNING" ]; then
if [ "$running_status" = "Started" ]; then
	if [ $debug_status = on ]; then
		echo '[DEBUG] Test Ksn_fe_running: OK' >> ../$1
		echo '[DEBUG] Prepare to stop case' >> ../$1
	fi
	#csn_stop $stop_status $1
	stop_status=`/export/ipm/client/_bin/ipm_client.shell.pl "/export/ipm/frontend" "stop" "/export/ipm/client/$1"`
	sleep 5
	if [ $debug_status = on ]; then
		echo '[DEBUG] stop_status = '$stop_status >> ../$1
	fi
	#if [ "$stop_status" = "KSN_FE_STOPPED" ]; then
	if [ "$stop_status" = "Stopped" ]; then
		if [ $debug_status = on ]; then
			echo '[DEBUG] Test Ksn_fe_stop: OK' >> ../$1
		fi
	else 
		if [ $debug_status = on ]; then
			echo '[DEBUG] Test Ksn_fe_stop: Fail' >> ../$1
		fi
		stop_fail=1
		if [ $stop_fail -eq 1 ]; then 
			testsfail=`expr $testsfail + 1`
			errorexist=`expr $errorexist + 1`
			if [ $debug_status = on ]; then
				echo '[DEBUG] Test '$2': Fail' >> ../$1
			fi
			echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
			echo '-------------<br>' >> ../mail_report					
			echo 'Test Ksn_fe_stop: Fail<br>' >> ../mail_report
			#echo '-------------logfileerror_stop' >> ../$1
			#echo '<br>-------------logfileerror_stop<br>' >> ../mail_report		
			#cat /export/ipm/client/_bin/logfileerror_stop >> ../$1
			#cat /export/ipm/client/_bin/logfileerror_stop >> ../mail_report		
			echo '-------------logfileout_stop' >> ../$1		
			echo '<br>-------------logfileout_stop<br>' >> ../mail_report			
			cat /export/ipm/client/_bin/logfileout_stop >> ../$1
			cat /export/ipm/client/_bin/logfileout_stop >> ../mail_report		
			echo '-------------' >> ../$1		
			echo '<br>-------------<br></td>' >> ../mail_report
			echo '<td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report	
		fi
	fi
	if [ $debug_status = on ]; then
		echo '[DEBUG] Prepare to start case' >> ../$1
	fi
	#csn_start $start_status $1
	start_status=`/export/ipm/client/_bin/ipm_client.shell.pl "/export/ipm/frontend" "start" "/export/ipm/client/$1"`
	sleep 5	
	if [ $debug_status = on ]; then
		echo '[DEBUG] start_status = '$start_status >> ../$1
	fi	
	#if [ "$start_status" = "KSN_FE_STARTED" ]; then
	if [ "$start_status" = "Started" ]; then
		if [ $debug_status = on ]; then
			echo '[DEBUG] Test Ksn_fe_start: OK' >> ../$1
		fi
		restart_pass=1
	else 
		if [ $debug_status = on ]; then
			echo '[DEBUG] Test Ksn_fe_start: Fail' >> ../$1
		fi
		start_fail=1
		if [ $start_fail -eq 1 ]; then 
			testsfail=`expr $testsfail + 1`
			errorexist=`expr $errorexist + 1`
			if [ $debug_status = on ]; then
				echo '[DEBUG] Test '$2': Fail' >> ../$1
			fi
			echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
			echo '-------------<br>' >> ../mail_report				
			echo 'Test Ksn_fe_start: Fail<br>' >> ../mail_report
			#echo '-------------logfileerror_start' >> ../$1
			#echo '<br>-------------logfileerror_start<br>' >> ../mail_report
			#cat /export/ipm/client/_bin/logfileerror_start >> ../$1
			#cat /export/ipm/client/_bin/logfileerror_start >> ../mail_report
			echo '-------------logfileout_start' >> ../$1		
			echo '<br>-------------logfileout_start<br>' >> ../mail_report		
			cat /export/ipm/client/_bin/logfileout_start >> ../$1
			cat /export/ipm/client/_bin/logfileout_start >> ../mail_report
			echo '-------------' >> ../$1			
			echo '<br>-------------<br></td>' >> ../mail_report
			echo '<td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report	
		fi
	fi
else
	if [ $debug_status = on ]; then 
		echo '[DEBUG] Test Ksn_fe_running: Fail' >> ../$1
		echo '[DEBUG] Test Ksn_fe_stop: Fail: KSN_FE_RUNNING' >> ../$1
		echo '[DEBUG] Test Ksn_fe_start: Fail: KSN_FE_RUNNING' >> ../$1
	fi
	check_fail=1
	if [ $check_fail -eq 1 ]; then 
		testsfail=`expr $testsfail + 1`
		errorexist=`expr $errorexist + 1`
		if [ $debug_status = on ]; then
			echo '[DEBUG] Test '$2': Fail' >> ../$1
		fi
		echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
		echo '-------------<br>' >> ../mail_report		
		echo 'Test Ksn_fe_running: Fail<br>' >> ../mail_report
		echo 'Test Ksn_fe_stop: Fail: KSN_FE_RUNNING<br>' >> ../mail_report
		echo 'Test Ksn_fe_start: Fail: KSN_FE_RUNNING<br>' >> ../mail_report
		#echo '-------------logfileerror_check' >> ../$1
		#echo '<br>-------------logfileerror_check<br>' >> ../mail_report
		#cat /export/ipm/client/_bin/logfileerror_check >> ../$1
		#cat /export/ipm/client/_bin/logfileerror_check >> ../mail_report
		echo '-------------logfileout_start' >> ../$1		
		echo '<br>-------------logfileout_start<br>' >> ../mail_report			
		cat /export/ipm/client/_bin/logfileout_start >> ../$1
		cat /export/ipm/client/_bin/logfileout_start >> ../mail_report	
		echo '-------------' >> ../$1			
		echo '-------------logfileout_stop' >> ../$1		
		echo '<br>-------------logfileout_stop<br>' >> ../mail_report			
		cat /export/ipm/client/_bin/logfileout_stop >> ../$1
		cat /export/ipm/client/_bin/logfileout_stop >> ../mail_report	
		echo '-------------' >> ../$1			
		echo '-------------<br>' >> ../mail_report	
		echo '<br>-------------<br></td>' >> ../mail_report		
		echo '<td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report	
	fi
fi
}

