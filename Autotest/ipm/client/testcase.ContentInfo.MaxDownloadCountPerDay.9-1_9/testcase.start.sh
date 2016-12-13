#!/bin/sh
run_test() {
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
debug_status=`cat /export/ipm/client/parameters.dat | grep debug_status | cut -f 2 -d =`
mail_logs_include=`cat /export/ipm/client/parameters.dat | grep mail_logs_include | cut -f 2 -d =`
log_tail_strings=`cat /export/ipm/client/parameters.dat | grep log_tail_strings | cut -f 2 -d =`
log_name=`cat /export/ipm/client/parameters.dat | grep log_name | cut -f 2 -d =`
save_date=`ssh $fe_ip_address "date +%Y%m%d%H%M"`
. ../testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9/case.sh
. ./ipm_frontend.restart.sh
ssh $fe_ip_address "cat /usr/local/csn/etc/ipm.monitrc | sed 's/--trace-level=700/--trace-level=900/g' >> /usr/local/csn/etc/ipm.monitrc_new"
ssh $fe_ip_address "mv /usr/local/csn/etc/ipm.monitrc_new /usr/local/csn/etc/ipm.monitrc"
run_restart $1 'testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9'
if [ $debug_status = on ]; then
	echo "[DEBUG] restart_pass = "$restart_pass
	echo "[DEBUG] restart_pass = "$restart_pass  >> ../$1
	echo "[DEBUG] check_fail = "$check_fail
	echo "[DEBUG] check_fail = "$check_fail  >> ../$1	
	echo "[DEBUG] start_fail = "$start_fail
	echo "[DEBUG] start_fail = "$start_fail  >> ../$1
	echo "[DEBUG] stop_fail = "$stop_fail
	echo "[DEBUG] stop_fail = "$stop_fail  >> ../$1	
fi
if [ $restart_pass -eq 1 ]; then 
	run_case $1 'testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9'
		if [ $debug_status = on ]; then
			echo '[DEBUG] save_date = '$save_date 
			echo '[DEBUG] pass = '$pass 
			echo '[DEBUG] pass = '$pass >> ../$1
			echo '[DEBUG] fail = '$fail
			echo '[DEBUG] fail = '$fail >> ../$1		
		fi	
	ssh $fe_ip_address "date $save_date"
else
	if [ $debug_status = on ]; then
		echo '[DEBUG] ContentInfo.MaxDownloadCountPerDay.9-1_9 : Fail' >> ../$1
	fi
	testsfail=`expr $testsfail + 1`
	errorexist=`expr $errorexist + 1`
	fail=1
	echo '<tr><td><b>Test testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9: </b><br>' >> ../mail_report
	echo '<br>case failed<br>' >> ../mail_report
	echo '<br>restart frontend fail<br>' >> ../mail_report
	if [ $mail_logs_include = yes ]; then
		cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >>  ../_mail_attaches/testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9.log
	fi			
	echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report		
fi
ssh $fe_ip_address "cat /usr/local/csn/etc/ipm.monitrc | sed 's/--trace-level=900/--trace-level=700/g' >> /usr/local/csn/etc/ipm.monitrc_new"
ssh $fe_ip_address "mv /usr/local/csn/etc/ipm.monitrc_new /usr/local/csn/etc/ipm.monitrc"
run_restart $1 'testcase.ContentInfo.MaxDownloadCountPerDay.9-1_9'
}
