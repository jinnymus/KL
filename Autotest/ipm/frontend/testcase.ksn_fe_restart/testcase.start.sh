#!/bin/sh
run_test() {
. ../_bin/csn_fe_check_running.sh
. ../_bin/csn_fe_stop.sh
. ../_bin/csn_fe_start.sh
running_status=0
stop_status=0
start_status=0
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
echo 'Start of functional test restart '$testdatetime
echo 'Start of functional test restart '$testdatetime >> ../$1
echo 'DEBUG = '$debug_status
if [ $debug_status = on ]; then
	echo '[DEBUG] Prepare to running'
	echo '[DEBUG] Prepare to running' >> ../$1
fi
#csn_check $running_status $1
running_status=`/export/ipm/frontend/_bin/ipm_frontend.nc.pl "/export/ipm/frontend" "/export/ipm/frontend/$1"`
echo '<tr><td><b>Test Ksn_fe_restart: </b>' >> ../mail_report
#if [ "$running_status" = "KSN_FE_RUNNING" ]; then
if [ "$running_status" = "Started" ]; then
	echo 'Test Ksn_fe_running: OK' >> ../$1
	#echo '<tr><td><b>Test Ksn_fe_running: </b></td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report	
	if [ $debug_status = on ]; then
		echo '[DEBUG] Prepare to stop case' >> ../$1
	fi
	#csn_stop $stop_status $1
	stop_status=`/export/ipm/frontend/_bin/ipm_frontend.shell.pl "/export/ipm/frontend" "stop" "/export/ipm/frontend/$1"`
	if [ $debug_status = on ]; then
		echo '[DEBUG] stop_status = '$stop_status >> ../$1
	fi
	#if [ "$stop_status" = "KSN_FE_STOPPED" ]; then
	if [ "$stop_status" = "Stopped" ]; then
		echo 'Test Ksn_fe_stop: OK' >> ../$1
		echo 'Test Ksn_fe_stop=OK' >> ../../status.dat		
		#echo '<tr><td><b>Test Ksn_fe_stop: </b></td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report			
	else 
		echo 'Test Ksn_fe_stop: Fail' >> ../$1
		echo 'Test Ksn_fe_stop=Fail' >> ../../status.dat		
		#echo '<tr><td><b>Test Ksn_fe_stop: </b></td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report		
		#echo '-------------logfileerror_stop' >> ../$1
		#echo '<br>-------------logfileerror_stop<br>' >> ../mail_report		
		#cat logfileerror_stop >> ../$1
		#cat logfileerror_stop >> ../mail_report		
		echo '-------------logfileout_stop' >> ../$1		
		echo '<br>-------------logfileout_stop<br>' >> ../mail_report			
		cat /export/ipm/frontend/_bin/logfileout_stop >> ../$1
		cat /export/ipm/frontend/_bin/logfileout_stop >> ../mail_report		
		echo '-------------' >> ../$1		
		echo '-------------<br>' >> ../mail_report
	fi
	if [ $debug_status = on ]; then
		echo '[DEBUG] Prepare to start case' >> ../$1
	fi
	#csn_start $start_status $1
	start_status=`/export/ipm/frontend/_bin/ipm_frontend.shell.pl "/export/ipm/frontend" "start" "/export/ipm/frontend/$1"`
	if [ $debug_status = on ]; then
		echo '[DEBUG] start_status = '$start_status >> ../$1
	fi	
	#if [ "$start_status" = "KSN_FE_STARTED" ]; then
	if [ "$start_status" = "Started" ]; then
		echo 'Test Ksn_fe_start: OK' >> ../$1
		echo 'Test Ksn_fe_start=OK' >> ../../status.dat			
		echo '</td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report	
		testspass=`expr $testspass + 1`
	else 
		echo 'Test Ksn_fe_start: Fail' >> ../$1
		echo 'Test Ksn_fe_start=Fail' >> ../../status.dat				
		#echo '-------------logfileerror_start' >> ../$1
		#echo '<br>-------------logfileerror_start<br>' >> ../mail_report
		#cat logfileerror_start >> ../$1
		#cat logfileerror_start >> ../mail_report
		echo '-------------logfileout_start' >> ../$1		
		echo '<br>-------------logfileout_start<br>' >> ../mail_report		
		cat /export/ipm/frontend/_bin/logfileout_start >> ../$1
		cat /export/ipm/frontend/_bin/logfileout_start >> ../mail_report
		echo '-------------' >> ../$1			
		echo '-------------<br>' >> ../mail_report	
		testsfail=`expr $testsfail + 1`
		errorexist=`expr $errorexist + 1`
		echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report	
	fi
else 
	echo 'Test Ksn_fe_running: Fail' >> ../$1
	echo 'Test Ksn_fe_running=Fail' >> ../../status.dat		
	echo 'Test Ksn_fe_stop: Fail: KSN_FE_RUNNING' >> ../$1
	#echo '<tr><td>Test Ksn_fe_stop: </td><td><font color="red"><b>Failed</b></font>: KSN_FE_RUNNING<br></td></tr>' >> ../mail_report
	echo 'Test Ksn_fe_start: Fail: KSN_FE_RUNNING' >> ../$1
	#echo '<tr><td>Test Ksn_fe_start: </td><td><font color="red"><b>Failed</b></font>: KSN_FE_RUNNING<br></td></tr>' >> ../mail_report
	echo '-------------logfileerror_check' >> ../$1
	echo '<br>-------------logfileerror_check<br>' >> ../mail_report
	#cat logfileerror_check >> ../$1
	#cat logfileerror_check >> ../mail_report
	echo '-------------logfileout_start' >> ../$1		
	echo '<br>-------------logfileout_start<br>' >> ../mail_report			
	cat /export/ipm/frontend/_bin/logfileout_start >> ../$1
	cat /export/ipm/frontend/_bin/logfileout_start >> ../mail_report	
	echo '-------------' >> ../$1			
	echo '-------------logfileout_stop' >> ../$1		
	echo '<br>-------------logfileout_stop<br>' >> ../mail_report			
	cat /export/ipm/frontend/_bin/logfileout_stop >> ../$1
	cat /export/ipm/frontend/_bin/logfileout_stop >> ../mail_report	
	echo '-------------' >> ../$1			
	echo '-------------<br>' >> ../mail_report	
	testsfail=`expr $testsfail + 1`
	errorexist=`expr $errorexist + 1`
	echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report			
fi
}

