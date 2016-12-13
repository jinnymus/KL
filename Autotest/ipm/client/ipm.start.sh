#!/bin/sh
/usr/sbin/ntpdate moscow11.avp.ru

cd /export/ipm/client/_bin
testing=`cat /export/ipm/client/parameters.dat | grep testing | cut -f 2 -d =`
testdatetime=`date +%d.%m.%y_%T`
csn_log_name=`echo 'ipm_client_functional_'$testdatetime'.log'`
mail_email_addreses_all=`cat ../parameters.dat | grep mail_email_addreses_all | cut -f 2 -d =`
ipm_server=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
monitor_exiting_time=`cat ../parameters.dat | grep monitor_exiting_time | cut -f 2 -d =`
mail_email_addreses_debug=`cat ../parameters.dat | grep mail_email_addreses_debug | cut -f 2 -d =`
debug_mail=`cat ../parameters.dat | grep debug_mail | cut -f 2 -d =`
package_url=`cat /export/parameters.dat | grep package_url | cut -f 2 -d =`
testplan_create=`cat ../parameters.dat | grep testplan_create | cut -f 2 -d =`
install_package=`cat ../parameters.dat | grep install_package | cut -f 2 -d =`
#sleep 200
rm -rf /export/ipm/client/*.log
rm -rf ../*.log
rm -rf *.log
rm -rf /export/ipm/client/mail_report_install_fail
rm -rf /export/ipm/client/logfileout_install
rm -rf /export/ipm/client/logfileerror_install
echo 'Start ipm client testing...' >> ../$csn_log_name
echo '________________________' >> ../$csn_log_name
echo '[DEBUG] testing = '$testing >> ../$csn_log_name
if [ $testing = on ]; then
	monitor_exiting_time=`cat ../parameters.dat | grep monitor_exiting_time | cut -f 2 -d =`
	#running_count=`cat ../../status.dat | grep -c frontend=Finished`
	running_count=`cat ../../status.dat | grep -c frontend=Running`
	echo '[DEBUG] Waiting time running_count = '$running_count		
	time_start=`date +%s`
	test_status=`cat ../../status.dat | grep -c Fail`
	echo '[DEBUG] test_status = '$test_status >> ../$csn_log_name					
	while [ $running_count -ne 0 ]
		do
		running_count=`cat ../../status.dat | grep -c frontend=Running`
		echo '[DEBUG] Waiting time running_count = '$running_count >> ../$csn_log_name		
		echo '[DEBUG] Waiting time running_count = '$running_count	
		time_end=`date +%s`
		time=`expr $time_end - $time_start`
		echo 'Time = '$time
		if [ $time -gt $monitor_exiting_time ]; then
			echo "[DEBUG] Time waiting (ipm_client) = "$monitor_exiting_time >> ../$csn_log_name
			echo "[DEBUG] Exiting (ipm_client)" >> ../$csn_log_name
			echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
			/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
			echo "[DEBUG] Changing status file" >> ../$csn_log_name
			cat ../../status.dat | sed 's/frontend=Finished/frontend=Stopped/g' > ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
			cat ../../status.dat | sed 's/client=Running/client=Fail/g' > ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
			exit
		fi
		sleep 15
	done
	echo '[DEBUG] Deleting log files' >> ../$csn_log_name
	file /usr/local/sbin/fping >> ../$csn_log_name
	fping=`/usr/local/sbin/fping $ipm_server | cut -f 3 -d " "`
	sleep 5
	echo "[DEBUG] fping = "$fping >> ../$csn_log_name
	echo "[DEBUG] ipm_server = "$ipm_server >> ../$csn_log_name	
	if [ "$fping" = "alive" ]; then
		echo '[DEBUG] Frontend is alive = '$fping >> ../$csn_log_name
		echo '[DEBUG] showmount check' >> ../$csn_log_name
		showmount=`showmount -e $ipm_server | grep / | cut -f 1 -d " "`
		if [ $showmount = /usr ]; then
			echo '[DEBUG] Try to mount' >> ../$csn_log_name
			./ipm_client.mount.sh
			echo '[DEBUG] Create testplan' >> ../$csn_log_name
			if [ $testplan_create = yes ]; then
				./ipm_client.testplan_create.sh
			fi
			monitor_exiting_time=`cat ../parameters.dat | grep monitor_exiting_time | cut -f 2 -d =`
			running_count=`cat ../../status.dat | grep -c frontend=Running`
			time_start=`date +%s`
			echo '[DEBUG] Changing status file' >> ../$csn_log_name
			cat ../../status.dat | sed 's/client=Stopped/client=Running/g' > ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
			test_status=`cat ../../status.dat | grep -c frontend=Fail`
			if [ $test_status -eq 0 ]; then
				echo '[DEBUG] test_status = '$test_status >> ../$csn_log_name					
				while [ $running_count -ne 0 ]
					do
					running_count=`cat ../../status.dat | grep -c frontend=Running`
					echo '[DEBUG] Waiting time running_count = '$running_count >> ../$csn_log_name		
					time_end=`date +%s`
					time=`expr $time_end - $time_start`
					echo 'Time = '$time
					if [ $time -gt $monitor_exiting_time ]; then
						echo "[DEBUG] Time waiting (ipm_client) = "$monitor_exiting_time >> ../$csn_log_name
						echo "[DEBUG] Exiting (ipm_client)" >> ../$csn_log_name
						echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
						/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
						echo "[DEBUG] Changing status file" >> ../$csn_log_name
						cat ../../status.dat | sed 's/frontend=Finished/frontend=Stopped/g' > ../../status_new.dat
						mv ../../status_new.dat ../../status.dat
						cat ../../status.dat | sed 's/client=Running/client=Fail/g' > ../../status_new.dat
						mv ../../status_new.dat ../../status.dat
						exit
					fi
					sleep 15
				done
				if [ -d /usr/local/csn2 ]; then
					echo "[DEBUG] Install not clear" >> ../$csn_log_name
					echo "Install not clear"
					echo "<b>Install not clear</b><br>" >> mail_report_install_not_clear
					echo '[DEBUG] Sending email' >> ../$csn_log_name
					echo "Sending email"
					/export/controller/controller.mail_send.pl mail_report_install_not_clear $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - Install not clear" "html"
					echo "Email sended"
					rm -rf mail_report_install_not_clear
					cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
					mv ../../status_new.dat ../../status.dat
				else
					echo "[DEBUG] Install is clear" >> ../$csn_log_name
					echo "[DEBUG] package_url = "$package_url >> ../$csn_log_name
					
					if [ $package_url = stable ]; then
						package_file=`ls /export/distrib/ipm_client`
						echo "[DEBUG] package_file = "$package_file >> ../$csn_log_name
						if [ $install_package = yes ]; then
							exec 8>&1 9>&2
							exec 1> /export/ipm/client/logfileout_install 2> /export/ipm/client/logfileerror_install
							pkg_add /export/distrib/ipm_client/$package_file
							exec 1>&8 2>&9
						fi
					else
						package_file_client=`ls /export/distrib/ipm_client`
						package_file_frontend=`ls /export/distrib/csn_frontend_exp`
						echo "[DEBUG] package_file_client = "$package_file_client >> ../$csn_log_name
						echo "[DEBUG] package_file_frontend = "$package_file_frontend >> ../$csn_log_name
						if [ $install_package = yes ]; then
							exec 8>&1 9>&2
							exec 1> /export/ipm/client/logfileout_install 2> /export/ipm/client/logfileerror_install
							pkg_add /export/distrib/ipm_client/$package_file_client
							pkg_add /export/distrib/csn_frontend_exp/$package_file_frontend
							exec 1>&8 2>&9
						fi
					fi

					if [ -f /usr/local/csn/utils/ipm/ipm_test ]; then
						echo "[DEBUG] Install ipm_client : Passed" >> ../$csn_log_name
						echo "[DEBUG] Start tests" >> ../$csn_log_name
						./ipm_client.start_tests.sh $csn_log_name
						echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
						/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
					else
						echo "[DEBUG] Install ipm_client : Failed" >> ../$csn_log_name
						echo "Install ipm_client : Failed"
						echo "<b>Install Failed</b><br>" >> mail_report_install_fail
						echo 'logfileout_install<br>' >> ../mail_report_install_fail
						cat /export/ipm/client/logfileout_install >> ../mail_report_install_fail
						echo '<br>logfileerror_install<br>' >> ../mail_report_install_fail
						cat /export/ipm/client/logfileerror_install >> ../mail_report_install_fail
						echo '[DEBUG] Sending email' >> ../$csn_log_name
						/export/controller/controller.mail_send.pl mail_report_install_fail $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - Install fail" "html"
						rm -rf mail_report_install_fail
						cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
						mv ../../status_new.dat ../../status.dat				
					fi
				fi
			else
				cd /export/ipm/client/_bin
				echo 'IPM functional client testing fail : Frontend Fail' >> ../$csn_log_name
				mv ../$csn_log_name /export/logs
				echo '[DEBUG] Frontend fail' >> ../$csn_log_name
				echo "Frontend fail"
				echo "<b>Frontend fail</b><br>" >> mail_report_frontend_fail
				echo '[DEBUG] Sending email' >> ../$csn_log_name
				/export/controller/controller.mail_send.pl mail_report_frontend_fail $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - Frontend fail" "html"
				rm -rf mail_report_frontend_fail
				cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
				mv ../../status_new.dat ../../status.dat
				echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
				/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
				echo "[DEBUG] Changing status file" >> ../$csn_log_name
			fi
		else
			cd /export/ipm/client/_bin
			echo '[DEBUG] Frontend showmount fail' >> ../$csn_log_name
			echo "Frontend showmount fail"
			echo "<b>Frontend showmount fail</b><br>" >> mail_report_frontend_showmount_fail
			echo '[DEBUG] Sending email' >> ../$csn_log_name
			/export/controller/controller.mail_send.pl mail_report_frontend_showmount_fail $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - Frontend showmount fail" "html"
			rm -rf mail_report_frontend_showmount_fail
			cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
			mv ../../status_new.dat ../../status.dat
			echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
			/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
			echo "[DEBUG] Changing status file" >> ../$csn_log_name
		fi
	else
		cd /export/ipm/client/_bin
		echo '[DEBUG] Frontend is unreachable = '$fping >> ../$csn_log_name
		echo "Frontend is unreachable"
		echo "<b>Frontend is unreachable</b><br>" >> mail_report_frontend_off
		echo '[DEBUG] Sending email' >> ../$csn_log_name
		/export/controller/controller.mail_send.pl mail_report_frontend_off $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - Frontend showmount fail" "html"
		rm -rf mail_report_frontend_off
		cat ../../status.dat | sed 's/client=Running/client=Fail/g' >> ../../status_new.dat
		mv ../../status_new.dat ../../status.dat
		echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
		/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
		echo "[DEBUG] Changing status file" >> ../$csn_log_name		
	fi
else
	cd /export/ipm/client/_bin
	echo "Testing off"
	echo "<b>Testing off</b><br>" >> mail_report_testing_off
	echo '[DEBUG] Sending email' >> ../$csn_log_name
	/export/controller/controller.mail_send.pl mail_report_testing_off $mail_email_addreses_debug "IPM. Functional test - Client. Debug info - No testing" "html"
	rm -rf mail_report_testing_off
	echo "[DEBUG] Changing finish.dat" >> ../$csn_log_name
	/export/controller/controller.finish_dat_edit.sh "ipm" "Running" "Finished"
	echo "[DEBUG] Changing status file" >> ../$csn_log_name
fi