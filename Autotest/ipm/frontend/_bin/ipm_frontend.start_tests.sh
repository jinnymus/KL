#!/bin/sh
cd /export/ipm/frontend/_bin
testdatetime=`date +%d.%m.%y_%T`
debug_status=`cat /export/ipm/frontend/parameters.dat | grep debug_status | cut -f 2 -d =`
log_name=`cat /export/ipm/frontend/parameters.dat | grep log_name | cut -f 2 -d =`
fe_reboot=`cat /export/ipm/status.dat | grep fe_reboot | cut -f 2 -d =`
testplan=`cat /export/ipm/frontend/testplan.dat`
mail_send_results=`cat /export/ipm/frontend/parameters.dat | grep mail_send_results | cut -f 2 -d =`
mail_send_debug=`cat /export/ipm/frontend/parameters.dat | grep mail_send_debug | cut -f 2 -d =`
mail_email_addreses_all=`cat /export/ipm/frontend/parameters.dat | grep mail_email_addreses_all | cut -f 2 -d =`
mail_email_addreses_debug=`cat /export/ipm/frontend/parameters.dat | grep mail_email_addreses_debug | cut -f 2 -d =`
debug_mail=`cat /export/ipm/frontend/parameters.dat | grep debug_mail | cut -f 2 -d =`
mail_email_addreses_fail=`cat /export/ipm/frontend/parameters.dat | grep mail_email_addreses_fail | cut -f 2 -d =`
package_url=`cat /export/parameters.dat | grep package_url | cut -f 2 -d =`
errorexist=0
testspass=0
testsfail=0
killall mountd
mountd
if [ $fe_reboot = yes ]; then
	datetime=`date +%d.%m.%y_%T`
	echo "[DEBUG] "$datetime" Starting OS 0..." >> ../$log_name
fi
if [ $package_url = stable ]; then
	package_file=`ls /export/distrib/csn_frontend`
	if [ -f /export/distrib/csn_frontend/$package_file ]; then
		status_file="found"
	else
		status_file="notfound"
	fi
else
	package_file=`ls /export/distrib/csn_frontend_exp`
	if [ -f /export/distrib/csn_frontend_exp/$package_file ]; then
		status_file="found"
	else
		status_file="notfound"
	fi
fi
if [ $fe_reboot = yes ]; then
	echo 'status_file = '$status_file >> ../$log_name
	echo 'package_file = '$package_file >> ../$log_name
fi
if [ $status_file = found ]; then
	if [ $fe_reboot = no ]; then
		rm -rf *.log
		rm -rf mail_report
		rm -rf ../mail_report
		testdatetime=`date +%d.%m.%y_%T`
		csn_log_name=`echo 'ipm_frontend_functional_'$testdatetime'.log'`
		rm -rf logfile*
		cat ../../status.dat | sed 's/frontend=Stopped/frontend=Running/g' >> ../../status_new.dat
		mv ../../status_new.dat ../../status.dat
		datetime=`date +%d.%m.%y_%T`
		echo "[DEBUG] "$datetime" Start of functional frontend tests" >> ../$csn_log_name
		echo "Start of functional frontend tests "$testdatetime"<br>" >> ../mail_report
		echo '_____________________' >> ../$csn_log_name
		echo "<br>" >> ../mail_report
		package_file=`ls /export/distrib/csn_frontend`
		echo "Testing package "$package_file >> ../mail_report
		echo "<br>" >> ../mail_report		
		echo '<br><table cols=2 border=1 style="word-wrap: break-word;" width=100%>' >> ../mail_report
		echo '<tr><td width=90%>Test name</td><td width=10%>Test result</td></tr>' >> ../mail_report
		cp -rf exports /etc
		if [ $debug_status = on ]; then
			datetime=`date +%d.%m.%y_%T`
			echo "[DEBUG] "$datetime" File exports was copied" >> ../$csn_log_name
			echo "[DEBUG] "$datetime" start pkg_add csn.tgz" >> ../$csn_log_name
		fi
		if [ -d /usr/local/csn ]; then
			echo "Install not clear"
			echo "<b>Install not clear</b><br>" >> mail_report_install_not_clear
			/export/controller/controller.mail_send.pl mail_report_install_not_clear $mail_email_addreses_debug "IPM. Functional test - Frontend. Debug info - Install not clear" "html"
			rm -rf mail_report_install_not_clear		
			cat ../../status.dat | sed 's/frontend=Running/frontend=Fail/g' >> ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
		else
			echo "Install is clear"
			rm -rf logfileerror_install
			rm -rf logfileout_install
			echo "Install is clear"
			exec 8>&1 9>&2
			exec 1> logfileout_install 2> logfileerror_install
			if [ $package_url = stable ]; then
				package_file=`ls /export/distrib/csn_frontend`
				pkg_add /export/distrib/csn_frontend/$package_file
			else
				package_file=`ls /export/distrib/csn_frontend_exp`
				pkg_add /export/distrib/csn_frontend_exp/$package_file
			fi
			#pkg_add /export/distrib/csn.tgz
			exec 1>&8 2>&9
			if [ $debug_status = on ]; then	
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime"  logfileout_install" >> ../$csn_log_name
				cat logfileout_install >> ../$csn_log_name
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime"  logfileerror_install" >> ../$csn_log_name
				cat logfileerror_install >> ../$csn_log_name	
				datetime=`date +%d.%m.%y_%T`				
				echo "[DEBUG] "$datetime"  package csn-dev-FreeBSD-8.2-RELEASE.tgz added" >> ../$csn_log_name
				echo "[DEBUG] "$datetime"  wait 30 seconds" >> ../$csn_log_name
			fi
			sleep 30
			echo "csn_frontend_enable=\"YES\"" >> /etc/rc.conf
			if [ $debug_status = on ]; then	
				echo '[DEBUG] rc.conf edited' >> ../$csn_log_name
			fi
			if [ -f /usr/local/etc/rc.d/csn_frontend ]; then 
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime" Test Frontend install : OK" >> ../$csn_log_name
				echo '<tr><td><b>Test Frontend install :</b></td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report
				#rm -rf /export/distrib/csn.tgz
				cat ../parameters.dat | sed 's/log_name='$log_name'/log_name='$csn_log_name'/g' > ../parameters_new.dat
				mv ../parameters_new.dat ../parameters.dat
				cat ../../status.dat | sed 's/fe_reboot=no/fe_reboot=yes/g' >> ../../status_new.dat
				mv ../../status_new.dat ../../status.dat
				/export/controller/controller.edit_monitrc.sh $csn_log_name
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime" Rebooting OS..." >> ../$csn_log_name
				echo '________________' >> ../$csn_log_name
				reboot
			else
				echo 'Test Frontend install : Fail' >> ../$csn_log_name
				echo '<tr><td><b>Test Frontend install : </b><br>' >> ../mail_report
				echo 'logfileout_install<br>' >> ../mail_report
				echo $res >> ../mail_report
				#cat logfileout_install >> ../mail_report
				#echo '<br>logfileerror_install<br>' >> ../mail_report
				#cat logfileerror_install >> ../mail_report
				echo '<br></td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report
				cat ../../status.dat | sed 's/frontend=Running/frontend=Fail/g' >> ../../status_new.dat
				mv ../../status_new.dat ../../status.dat
				testsfail=`expr $testsfail + 1`
				errorexist=`expr $errorexist + 1`
			fi
		fi
	fi	
	if [ $fe_reboot = yes ]; then
		echo '________________' >> ../$log_name
		datetime=`date +%d.%m.%y_%T`
		echo $datetime' Starting OS...' >> ../$log_name
		echo 'Wait 120 seconds for starting frontend...' >> ../$log_name	
		sleep 120
		datetime=`date +%d.%m.%y_%T`
		echo "[DEBUG] "$datetime" Start testcases" >> ../$log_name
		echo 'Start testcases'
		testspass=`expr $testspass + 1`
		for test in $testplan
		do
			datetime=`date +%d.%m.%y_%T`
			echo "[DEBUG] "$datetime" Start testcase "$test >> ../$log_name
			echo 'Start testcase '$test
			cd ../$test
			. ./testcase.start.sh
			if [ $debug_status = on ]; then
				pwd=`pwd`
				datetime=`date +%d.%m.%y_%T`
				echo '[DEBUG] '$datetime' pwd = '$pwd >> ../$log_name
				echo '[DEBUG] '$datetime' Try to run_test '$test >> ../$log_name
			fi
			run_test $log_name $errorexist $testspass $testsfail
			rm -rf log*
			if [ $debug_status = on ]; then
				datetime=`date +%d.%m.%y_%T`
				echo '[DEBUG] '$datetime' errorexist = '$errorexist 
				echo '[DEBUG] '$datetime' testspass = '$testspass 
				echo '[DEBUG] '$datetime' testsfail = '$testsfail
			fi
			cd /export/ipm/frontend/_bin
		done
		if [ $debug_status = on ]; then
			datetime=`date +%d.%m.%y_%T`
			echo '[DEBUG] '$datetime' Try to start frontend after client testing' >> ../$log_name
			pwd=`pwd`
			datetime=`date +%d.%m.%y_%T`			
			echo '[DEBUG] '$datetime' pwd = '$pwd >> ../$log_name
		fi
		/usr/local/etc/rc.d/csn_frontend start >> ../$log_name
		if [ $testsfail -gt 0 ]; then
			cat ../../status.dat | sed 's/frontend=Running/frontend=Fail/g' >> ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
		else
			cat ../../status.dat | sed 's/frontend=Running/frontend=Finished/g' >> ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
		fi
		echo '</table><br>' >> ../mail_report
		echo 'Status changed' >> ../$log_name
		echo '_____________________' >> ../$log_name
		echo 'Frontend log ended' >> ../$log_name
		echo 'End of functional tests' >> ../$log_name
		echo 'End of functional tests<br>' >> ../mail_report
		echo 'Tests passed = '$testspass  >> ../$log_name
		echo 'Tests passed = <b>'$testspass'</b><br>'  >> ../mail_report
		echo 'Tests passed = '$testspass
		echo 'Tests failed = '$testsfail  >> ../$log_name
		echo 'Tests failed = <b>'$testsfail'</b><br>'  >> ../mail_report
		echo 'Tests failed = '$testsfail
		echo 'Testing ended with '$errorexist' errors'  >> ../$log_name
		echo 'Testing ended with <b>'$errorexist'</b> errors<br>'  >> ../mail_report
		echo 'Testing ended with '$errorexist' errors'
		echo 'End of functional tests'	
		if [ $debug_status = on ]; then
			datetime=`date +%d.%m.%y_%T`
			echo "[DEBUG] "$datetime" = "$debug_status  >> ../$log_name
			echo "[DEBUG] "$datetime" mail_send_results = "$mail_send_results >> ../$log_name
			echo "[DEBUG] "$datetime" mail_send_debug = "$mail_send_debug >> ../$log_name	
			echo "[DEBUG] "$datetime" mail_email_addreses_all = "$mail_email_addreses_all >> ../$log_name
		fi
		if [ $mail_send_results = yes  ]; then
			mail_subject=`echo 'IPM. Functional test - Frontend. Pass '$testspass'. Fail '$testsfail`
			if [ $debug_status = on ]; then
				datetime=`date +%d.%m.%y_%T`
				echo '[DEBUG] '$datetime' Sending email notification report'  >> ../$log_name
			fi
			if [ $mail_send_debug = yes ]; then
				if [ $debug_status = on ]; then	
					datetime=`date +%d.%m.%y_%T`
					echo '[DEBUG] '$datetime' Sending debug log'  >> ../$log_name	
				fi			
				echo '[DEBUG] '$datetime' ail_subject = '$mail_subject >> ../$log_name
				pwd=`pwd`
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime" pwd = "$pwd >> ../$log_name
				echo "[DEBUG] "$datetime" try send mail" >> ../$log_name
				echo "[DEBUG] "$datetime" mail_email_addreses_all = "$mail_email_addreses_all >> ../$log_name
				if [ $debug_mail = on ]; then
					/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$log_name ../mail			
				else
					/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_all "$mail_subject" "multipart" ../$log_name ../mail
				fi		
				if [ $debug_status = on ]; then			
					echo '[DEBUG] '$datetime' Debug log sended'  >> ../$log_name			
				fi
				if [ $testsfail -gt 0 ]; then
					if [ $debug_mail = on ]; then
						/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$log_name ../mail				
					else
						/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_fail "$mail_subject" "multipart" ../$log_name ../mail
					fi				
				fi
			else
				pwd=`pwd`
				datetime=`date +%d.%m.%y_%T`
				echo "[DEBUG] "$datetime" pwd = "$pwd >> ../$log_name
				echo "[DEBUG] "$datetime" try send mail" >> ../$log_name
				if [ $debug_mail = on ]; then		
					/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "html"
					if [ $testsfail -gt 0 ]; then
						/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_debug "$mail_subject" "multipart" ../$log_name ../mail
					fi
				else
					/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_all "$mail_subject" "html"
					if [ $testsfail -gt 0 ]; then
						/export/controller/controller.mail_send.pl ../mail_report $mail_email_addreses_fail "$mail_subject" "multipart" ../$log_name ../mail
					fi
				fi
			fi
			if [ $debug_status = on ]; then		
				datetime=`date +%d.%m.%y_%T`
				echo '[DEBUG] '$datetime' Notification report sended'  >> ../$log_name	
			fi		
		fi
		cp -rf ../mail_report /export/results/ipm_frontend.autotesting_results.$testdatetime.html
		rm -rf ../mail_report
		mv ../$log_name /export/logs
		mountd
	fi
else
	echo 'Frontend log started' >> ../$log_name
	echo '_____________________' >> ../$log_name
	testdatetime=`date +%d.%m.%y_%T`
	csn_log_name=`echo 'ipm_frontend_functional_'$testdatetime'.log'`
	mail_subject = `echo 'IPM. Functional test - Frontend. Debug info - File distrib not exist'`
	echo 'File /export/distrib/csn_frontend/'$package_file' not exist'
	echo 'File /export/distrib/csn_frontend/'$package_file' not exist' >> ../$log_name
	echo 'File /export/distrib/csn_frontend/'$package_file' not exist' >> /export/ipm/frontend/_bin/mail_report_distrib_notexist
	echo '_____________________' >> ../$log_name
	echo 'Frontend log ended' >> ../$log_name
	if [ $debug_mail = on ]; then
		/export/controller/controller.mail_send.pl /export/ipm/frontend/_bin/mail_report_distrib_notexist $mail_email_addreses_debug "$mail_subject" "multipart" ../$log_name ../mail			
	else
		/export/controller/controller.mail_send.pl /export/ipm/frontend/_bin/mail_report_distrib_notexist $mail_email_addreses_fail "$mail_subject" "multipart" ../$log_name ../mail	
	fi		
	rm -rf /export/ipm/frontend/_bin/mail_report_distrib_notexist	
fi


