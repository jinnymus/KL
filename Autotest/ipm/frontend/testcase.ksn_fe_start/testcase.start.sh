#!/bin/sh
run_test() {
. ../_bin/csn_fe_start.sh
start_status=0
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
echo 'Start of functional test start '$testdatetime
echo 'Start of functional test start '$testdatetime >> ../$1
echo 'DEBUG = '$debug_status
if [ $debug_status = on ]; then
	echo '[DEBUG] Prepare to start case' >> ../$1
fi
#csn_start $start_status $1
start_status=`/export/ipm/frontend/_bin/ipm_frontend.shell.pl "/export/ipm/frontend" "start" "/export/ipm/frontend/$1"`
if [ $debug_status = on ]; then
	echo '[DEBUG] start_status = '$start_status >> ../$1
fi	
echo '<tr><td><b>Test Ksn_fe_start: </b>' >>../mail_report
#if [ "$start_status" = "KSN_FE_STARTED" ]; then
if [ "$start_status" = "Started" ]; then
	echo 'Test Ksn_fe_start: OK' >> ../$1
	echo 'Test Ksn_fe_start=OK' >> ../../status.dat	
	echo '</td><td><font color="green"><b>Passed</b></font><br></td></tr>' >>../mail_report
	testspass=`expr $testspass + 1`
else 
	echo 'Test Ksn_fe_start: Fail' >> ../$1
	echo 'Test Ksn_fe_start=Fail' >> ../../status.dat	

	#echo '-------------logfileerror_start' >> ../$1
	#echo '<br>-------------logfileerror_start<br>' >> ../mail_report
	#cat logfileerror_start >> ../$1
	#cat logfileerror_start >> ../mail_report
	echo '-------------logfileout_start' >> ../$1		
	echo '<br>-------------logfileout_start<br>' >>../mail_report		
	cat /export/ipm/frontend/_bin/logfileout_start >> ../$1
	cat /export/ipm/frontend/_bin/logfileout_start >>../mail_report
	echo '-------------' >> ../$1			
	echo '-------------<br>' >>../mail_report
	testsfail=`expr $testsfail + 1`
	errorexist=`expr $errorexist + 1`
	echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >>../mail_report	
fi
}