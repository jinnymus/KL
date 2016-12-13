#!/bin/sh
run_test() {
. ../_bin/csn_fe_stop.sh
stop_status=0
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
echo 'Start of functional test stop '$testdatetime
echo 'Start of functional test stop '$testdatetime >> ../$1
echo 'DEBUG = '$debug_status
if [ $debug_status = on ]; then
	echo '[DEBUG] Prepare to stop case' >> ../$1
	echo '[DEBUG] log name = '$1 >> ../$1
fi
stop_status=`/export/ipm/frontend/_bin/ipm_frontend.shell.pl "/export/ipm/frontend" "stop" "/export/ipm/frontend/$1"`
#csn_stop $stop_status $1
if [ $debug_status = on ]; then
	echo '[DEBUG] stop_status = '$stop_status >> ../$1
fi
echo '<tr><td><b>Test Ksn_fe_stop: </b>' >>../mail_report
#if [ "$stop_status" = "KSN_FE_STOPPED" ]; then
if [ "$stop_status" = "Stopped" ]; then
	echo 'Test Ksn_fe_stop: OK' >> ../$1
	echo 'Test Ksn_fe_stop=OK' >> ../../status.dat	
	echo '</td><td><font color="green"><b>Passed</b></font><br></td></tr>' >>../mail_report
	testspass=`expr $testspass + 1`	
else 
	echo 'Test Ksn_fe_stop: Fail' >> ../$1
	echo 'Test Ksn_fe_stop=Fail' >> ../../status.dat			
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
	testsfail=`expr $testsfail + 1`
	errorexist=`expr $errorexist + 1`
	echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >>../mail_report		
fi
}
