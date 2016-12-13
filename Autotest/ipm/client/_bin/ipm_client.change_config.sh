#!/bin/sh
run_change_config() {
. ./ipm_frontend.restart.sh
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
mail_logs_include=`cat ../parameters.dat | grep mail_logs_include | cut -f 2 -d =`
log_tail_strings=`cat ../parameters.dat | grep log_tail_strings | cut -f 2 -d =`
log_name=`cat ../parameters.dat | grep log_name | cut -f 2 -d =`
restart_pass=0
stop_fail=0
start_fail=0
check_fail=0
pass=0
fail=0
if [ $debug_status = on ]; then
	echo '[DEBUG] ######################################################' >> ../$1
fi
echo 'Running test '$2
if [ $debug_status = on ]; then
	echo '[DEBUG] '$2' : Start' >> ../$1
fi
if [ $debug_status = on ]; then
	echo '[DEBUG] Backup frontend config'
	echo '[DEBUG] Backup frontend config' >> ../$1
fi
ssh $fe_ip_address "/export/ipm/frontend/_bin/ipm_frontend.backup_config.sh $3"
if [ $debug_status = on ]; then
	echo '[DEBUG] Change config'
	echo '[DEBUG] Change config' >> ../$1
fi	
param_value=`ssh $fe_ip_address "cat /usr/local/csn/etc/$3 | grep $4 | cut -f 2 -d ="`
if [ $debug_status = on ]; then
	echo '[DEBUG] param_value = '$param_value
	echo '[DEBUG] param_value = '$param_value >> ../$1
fi	
ssh $fe_ip_address "cat /usr/local/csn/etc/$3 | sed 's/$4=$param_value/$4=$5/g' >> /usr/local/csn/etc/$3.new" 
if [ $debug_status = on ]; then
	echo '[DEBUG] Move config'
	echo '[DEBUG] Move config' >> ../$1
fi	
ssh $fe_ip_address "mv /usr/local/csn/etc/$3.new /usr/local/csn/etc/$3" 
if [ $debug_status = on ]; then
	echo '[DEBUG] Config changed'
	echo '[DEBUG] Config changed' >> ../$1
	echo '[DEBUG] Prepare to run_restart'
	echo '[DEBUG] Prepare to run_restart' >> ../$1
fi
run_restart $1 $2
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
	if [ $debug_status = on ]; then
		echo '[DEBUG] restart_pass : OK' >> ../$1
	fi
	cd ../$2
	. ./$6
	if [ $debug_status = on ]; then
		echo '[DEBUG] start run_case'
		echo '[DEBUG] start run_case' >> ../$1
	fi	
	run_case $1
	if [ $debug_status = on ]; then
		echo '[DEBUG] pass = '$pass 
		echo '[DEBUG] pass = '$pass >> ../$1
		echo '[DEBUG] fail = '$fail
		echo '[DEBUG] fail = '$fail >> ../$1		
	fi		
	cd ../_bin
	if [ $debug_status = on ]; then
		echo '[DEBUG] Restore frontend config'
		echo '[DEBUG] Restore frontend config' >> ../$1
	fi
	ssh $fe_ip_address "/export/ipm/frontend/_bin/ipm_frontend.restore_config.sh $3"
	if [ $debug_status = on ]; then
		echo '[DEBUG] Prepare to run_restart 2'
		echo '[DEBUG] Prepare to run_restart 2' >> ../$1
	fi
	run_restart $1 $2
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
		if [ $debug_status = on ]; then
			echo '[DEBUG] restart_pass 2 : OK' >> ../$1
		fi
		if [ $pass -eq 1 ]; then 
			if [ $debug_status = on ]; then
				echo '[DEBUG] '$2' : OK' >> ../$1
			fi
			testspass=`expr $testspass + 1`
			echo '<tr><td><b>Test '$2': </b></td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report	
		elif [ $fail -eq 1 ]; then
			if [ $debug_status = on ]; then
				echo '[DEBUG] '$2' : Fail' >> ../$1
			fi
			testsfail=`expr $testsfail + 1`
			errorexist=`expr $errorexist + 1`
			fail=1
			echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
			echo '<br>case failed<br>' >> ../mail_report
			echo '<br>result = '$result'<br>' >> ../mail_report
			if [ $mail_logs_include = yes ]; then
				tail -$log_tail_strings ../_logs/$log_name >> ../_mail_attaches/$2.log
			fi			
			echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report				
		fi
	fi
else
	if [ $debug_status = on ]; then
		echo '[DEBUG] Restore frontend config'
		echo '[DEBUG] Restore frontend config' >> ../$1
	fi
	ssh $fe_ip_address "/export/ipm/frontend/_bin/ipm_frontend.restore_config.sh $3"
fi
if [ $debug_status = on ]; then
	echo '[DEBUG] '$2' : End' >> ../$1
	echo '_____________________' >> ../$1
fi
rm -rf /export/ipm/client/_bin/logfile*
}
