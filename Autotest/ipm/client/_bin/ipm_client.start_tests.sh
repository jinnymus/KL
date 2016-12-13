#!/bin/sh
tests=`cat ../testplan.dat`
errorexist=0
testspass=0
testsfail=0
testdatetime=`date +%d.%m.%y_%T`
#csn_log_name=`echo 'ipm_client_functional_'$testdatetime'.log'`
csn_log_name=`echo $1`
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
mail_send_results=`cat ../parameters.dat | grep mail_send_results | cut -f 2 -d =`
mail_send_debug=`cat ../parameters.dat | grep mail_send_debug | cut -f 2 -d =`
mail_email_addreses_all=`cat ../parameters.dat | grep mail_email_addreses_all | cut -f 2 -d =`
mail_email_addreses_fail=`cat ../parameters.dat | grep mail_email_addreses_fail | cut -f 2 -d =`
mail_email_addreses_debug=`cat ../parameters.dat | grep mail_email_addreses_debug | cut -f 2 -d =`
debug_mail=`cat ../parameters.dat | grep debug_mail | cut -f 2 -d =`
rm -rf ../mail_report
rm -rf ../_mail_attaches/*
if [ $debug_status = on ]; then
	echo "[DEBUG] = "$debug_status  >> ../$csn_log_name
	echo "[DEBUG] mail_send_results = "$mail_send_results >> ../$csn_log_name
	echo "[DEBUG] mail_send_debug = "$mail_send_debug >> ../$csn_log_name	
	echo "[DEBUG] mail_email_addreses_all = "$mail_email_addreses_all >> ../$csn_log_name
fi
printf 'Start of functional client tests '$testdatetime'\n'
printf "Start of functional client tests "$testdatetime"\n" >> ../$csn_log_name
printf "Start of functional client tests "$testdatetime"\n<br>" >> ../mail_report
echo '_____________________' >> ../$csn_log_name
#echo '<br><style type="text/css">td { word-wrap: break-word; } </style><br>' >> ../mail_report
echo '<br><table cols=2 border=1 style="word-wrap: break-word;" width=100%>' >> ../mail_report
echo '<tr><td width=90%>Test name</td><td width=10%>Test result</td></tr>' >> ../mail_report
exec 8>&1 9>&2
exec 1> /export/ipm/client/logfileout_testing.log 2> /export/ipm/client/logfileerror_testing.log
for test in $tests
do
	if [ -f ../$test/testcase.start.sh ]; then
		if [ $debug_status = on ]; then
			echo '[DEBUG] ######################################################' >> ../$csn_log_name
			echo "[DEBUG] Testing test "$test >> ../$csn_log_name
			pwd=`pwd`
			echo "[DEBUG] pwd = "$pwd >> ../$csn_log_name
		fi
		. ../$test/testcase.start.sh
		fail=0
		if [ $debug_status = on ]; then
			echo '[DEBUG] fail = '$fail >> ../$csn_log_name
		fi		
		run_test $csn_log_name $test $errorexist $testspass $testsfail $fail
		if [ $debug_status = on ]; then
			echo '[DEBUG] fail = '$fail >> ../$csn_log_name
		fi			
		if [ $debug_status = on ]; then
			echo '[DEBUG] '$test' : End' >> ../$csn_log_name
		fi
		echo $test' : End' >> ../$csn_log_name
		echo '_____________________' >> ../$csn_log_name
		if [ $fail -eq 1 ]; then
			#../_mail_attaches/
			echo "Test "$test" failed"
			cd /export/ipm/client/$test
			tar -cvf /export/ipm/client/_mail_attaches/$test.tar *
			cd /export/ipm/client/_bin			
		fi
		if [ $debug_status = on ]; then
			pwd=`pwd`
			echo "[DEBUG] pwd = "$pwd >> ../$csn_log_name
		fi			
	else
		. ./ipm_client.test_run.sh
		symbol=`echo $test | cut -c 1`
		if [ $debug_status = on ]; then
			echo '[DEBUG] symbol = '$symbol >> ../$csn_log_name
		fi
		if [ $symbol != "#" ]; then
			fail=0
			if [ $debug_status = on ]; then
				echo '[DEBUG] fail = '$fail >> ../$csn_log_name
			fi				
			run_test $csn_log_name $test $errorexist $testspass $testsfail $fail
			if [ $debug_status = on ]; then
				echo '[DEBUG] fail = '$fail >> ../$csn_log_name
			fi				
		fi
		if [ $fail -eq 1 ]; then
			#../_mail_attaches/
			echo "Test "$test" failed"
			cd /export/ipm/client/$test
			tar -cvf /export/ipm/client/_mail_attaches/$test.tar *
			cd /export/ipm/client/_bin
		fi		
		if [ $debug_status = on ]; then
			pwd=`pwd`
			echo "[DEBUG] pwd = "$pwd >> ../$csn_log_name
		fi		
	fi
done;

exec 1>&8 2>&9
#echo "[DEBUG] logfileout_testing" >> ../$csn_log_name
#echo "[DEBUG] =========================================================================" >> ../$csn_log_name
#echo "[DEBUG] =========================================================================" >> ../$csn_log_name
#cat /export/ipm/client/logfileout_testing.log >> ../$csn_log_name
cp -rf /export/ipm/client/logfileout_testing.log /export/ipm/client/_mail_attaches
#echo "[DEBUG] logfileerror_testing" >> ../$csn_log_name
#echo "[DEBUG] =========================================================================" >> ../$csn_log_name
#echo "[DEBUG] =========================================================================" >> ../$csn_log_name
#cat /export/ipm/client/logfileerror_testing.log >> ../$csn_log_name
cp -rf /export/ipm/client/logfileerror_testing.log /export/ipm/client/_mail_attaches

echo '</table><br>' >> ../mail_report
echo 'End of functional tests' >> ../$csn_log_name
echo 'End of functional tests<br>' >> ../mail_report
echo 'Tests passed = '$testspass  >> ../$csn_log_name
echo 'Tests passed = <b>'$testspass'</b><br>'  >> ../mail_report
echo 'Tests passed = '$testspass
echo 'Tests failed = '$testsfail  >> ../$csn_log_name
echo 'Tests failed = <b>'$testsfail'</b><br>'  >> ../mail_report
echo 'Tests failed = '$testsfail
echo 'Testing ended with '$errorexist' errors'  >> ../$csn_log_name
echo 'Testing ended with <b>'$errorexist'</b> errors<br>'  >> ../mail_report
echo 'Testing ended with '$errorexist' errors'
echo 'End of functional tests'
echo '_____________________' >> ../$csn_log_name
echo "[DEBUG] Changing status file" >> ../$csn_log_name
echo "Check testsfail"
if [ $testsfail -gt 0 ]; then
	cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
	mv ../../status_new.dat ../../status.dat
else
	cat ../../status.dat | sed 's/client=Running/client=Finished/g' > ../../status_new.dat
	mv ../../status_new.dat ../../status.dat
fi
if [ $mail_send_results = yes ]; then
	mail_subject=`echo 'IPM. Functional test - Client. Pass '$testspass'. Fail '$testsfail`
	if [ $debug_status = on ]; then
		echo '[DEBUG] Sending email notification report'  >> ../$csn_log_name
	fi
	echo "Check mail_send_debug"
	if [ $mail_send_debug = yes ]; then
		echo "mail_send_debug = yes"
		if [ $debug_status = on ]; then	
			echo '[DEBUG] Sending debug log'  >> ../$csn_log_name	
		fi			
		echo '[DEBUG] mail_subject = '$mail_subject >> ../$csn_log_name
		if [ $debug_mail = on ]; then
			/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches			
		else
			/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_all "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches
		fi	
		if [ $debug_status = on ]; then			
			echo '[DEBUG] Debug log sended'  >> ../$csn_log_name			
		fi
		if [ $testsfail -gt 0 ]; then
			if [ $debug_mail = on ]; then
				/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches				
			else
				/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_fail "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches
			fi			
		fi
	else
		echo "mail_send_debug = no"

		if [ $debug_mail = on ]; then
			/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "html"
			if [ $testsfail -gt 0 ]; then
				/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches
			fi
		else
			/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_all "$mail_subject" "html"
			if [ $testsfail -gt 0 ]; then
				/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_fail "$mail_subject" "multipart" ../$csn_log_name ../_mail_attaches
			fi
		fi			
	fi
	if [ $debug_status = on ]; then		
		echo '[DEBUG] Notification report sended'  >> ../$csn_log_name	
	fi		
fi
cp -rf ../mail_report /export/results/ipm_client.autotesting_results.$testdatetime.html
rm -rf ../mail_report
mv ../$csn_log_name /export/logs