#!/bin/sh
#. ./controller.finish_monitor.sh
# Checking parameters of calling script
if [ -z $1 ]; then
	echo "First parameter is null"
else
	if [ -z $2 ]; then
		echo "Second parameter is null"
	else
		# Checking parameters of calling script
		status=`cat /export/status.dat | grep controller | cut -f 2 -d =`
		mail_email_addreses=`cat /export/parameters.dat | grep mail_email_addreses | cut -f 2 -d =`
		# Checking controller status Running/Stopped testing
		echo 'controller status = '$status
		
		if [ $status = Stopped ]; then
			# Changing controller status to Running testing
			rm /export/controller/mail_report*
			cat /export/status.dat | sed 's/controller=Stopped/controller=Running/g' > /export/status_new.dat
			mv /export/status_new.dat /export/status.dat
			cd /export/controller
			rm -rf *.log
			# Get test parameters from file
			testdatetime=`date +%d.%m.%y_%T`
			controller_log_name=`echo 'controller_functional_'$testdatetime'.log'`
			debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
			mail_send_results=`cat ../parameters.dat | grep mail_send_results | cut -f 2 -d =`
			testing=`cat ../parameters.dat | grep testing | cut -f 2 -d =`
			controller_esx_ip=`cat ../parameters.dat | grep controller_esx_ip | cut -f 2 -d =`
			package_url=`cat /export/parameters.dat | grep package_url | cut -f 2 -d =`
			echo 'controller testing = '$testing
			echo "Start "$testdatetime
			# Checking testing status on/off
			if [ $testing = on ]; then
				echo 'Start testing' >> $controller_log_name
				echo '=============' >> $controller_log_name
				echo 'URL1 = '$1 >> $controller_log_name
				echo 'URL2 = '$2 >> $controller_log_name
				echo 'controller.delete_temporary_files.sh start ' >> $controller_log_name	
				# Script for deleting temp files of previous testing
				./controller.delete_temporary_files.sh $controller_log_name
				echo 'controller.delete_temporary_files.sh started ' >> $controller_log_name
				echo 'controller.status_updater.sh start ' >> $controller_log_name	
				# Script for update status Running for all machines into testplan
				./controller.status_updater.sh $controller_log_name
				echo 'controller.status_updater.sh started ' >> $controller_log_name	
				echo 'controller.download.sh start ' >> $controller_log_name
				# Script for download packages
				./controller.download.sh "csn" $1 $controller_log_name
				./controller.download.sh "ipm_client" $2 $controller_log_name
				# Checking existing downloaded packages
				if [ $package_url = stable ]; then
					echo 'Distrib csn.tgz' >> $controller_log_name
					package_csn="csn.tgz"
				else
					echo 'Distrib csn_exp.tgz' >> $controller_log_name
					package_csn="csn_exp.tgz"
				fi
				file1=`echo $1 | rev | cut -f 1 -d / | rev`
				file2=`echo $2 | rev | cut -f 1 -d / | rev`
				if [ -f /export/distrib/csn_frontend/$file1 ]; then
					echo 'Distribs found'
					echo 'Distribs found' >> $controller_log_name
					echo 'Distribs found file1 = '$file1 >> $controller_log_name
					echo 'Distribs found file2 = '$file2 >> $controller_log_name		
					tcpd_test=`cat /export/parameters.dat | grep tcpd_test | cut -f 2 -d =`
					if [ $tcpd_test = yes ]; then
						echo 'tcpd_test yes' >> $controller_log_name
						/export/tcpd/tcpd.start.pl /export/distrib/csn_frontend/$file1 &
					else
						echo 'tcpd_test no' >> $controller_log_name
					fi					
				else
					echo 'Distribs not found'
					echo 'Distribs not found' >> $controller_log_name
					echo 'Distribs not found file1 = '$file1 >> $controller_log_name
					echo 'Distribs not found file2 = '$file2 >> $controller_log_name
					echo "Build detected. But distribs not found"
					echo "<b>Build detected. But distribs not found</b><br>" >> mail_report_not_comlete
					echo "Call parameters:<br>" >> mail_report_not_comlete
					echo "1 = "$1"<br>" >> mail_report_not_comlete
					echo "2 = "$2"<br>" >> mail_report_not_comlete
					# Mailing of downloading error
					/export/controller/controller.mail_send.pl mail_report_not_comlete $mail_email_addreses 'Controller. Functional tests. Debug. Build detected. But distribs not found' "html"
					rm -rf mail_report_not_comlete
					# Update controller status to Stopped
					cat /export/status.dat | sed 's/controller=Running/controller=Stopped/g' > /export/status_new.dat
					mv /export/status_new.dat /export/status.dat
					# Return donwload error code
					echo "autotests_code=888"
					exit
				fi
				echo 'controller.download.sh started ' >> $controller_log_name
				echo 'controller.p4_sync.sh.sh start ' >> $controller_log_name	
				# Script for download sources from perforce
				./controller.p4_sync.sh $controller_log_name
				echo 'controller.p4_sync.sh.sh started ' >> $controller_log_name
				echo 'controller.finish_dat_create.sh start ' >> $controller_log_name
				# Script for create finish.dat file for monitoring status testing all services
				/export/controller/controller.finish_dat_create.sh $controller_log_name
				echo 'controller.finish_dat_create.sh started ' >> $controller_log_name
				echo 'controller.finish_monitor.sh start ' >> $controller_log_name	
				# Script for run finish monitor for monitoring status testing all services. Running as thread for run next scripts
				./controller.finish_monitor.sh $controller_log_name $1 $2 &
				echo 'controller.finish_monitor.sh started ' >> $controller_log_name
				echo 'controller.esx_revert.sh start ' >> $controller_log_name
				echo 'controller.esx_revert.sh started'
				# Call esx controller machine to ssh with script for revert clear snepshots for all machines in testplan
				ssh $controller_esx_ip "/export/controller/controller.esx_revert.sh "$controller_log_name
				echo 'controller.esx_revert.sh started ' >> $controller_log_name
				
				echo 'controller.waiting.sh start' >> $controller_log_name
				# Script for waiting finishing all testing process for return result error code 0 SUCCESS)
				./controller.waiting.sh $controller_log_name			
				echo 'controller.waiting.sh started' >> $controller_log_name
				echo '=============' >> $controller_log_name
				echo 'controller log ended' >> $controller_log_name
				#mv $controller_log_name /export/logs				
				
			else
				echo 'Testing is off' >> $controller_log_name
			fi
		else
			# Mailing for testing not else finished
			echo "Build detected. But testing not completed"
			echo "<b>Build detected. But testing not completed</b><br>" >> mail_report_not_comlete
			echo "Call parameters:<br>" >> mail_report_not_comlete
			echo "1 = "$1"<br>" >> mail_report_not_comlete
			echo "2 = "$2"<br>" >> mail_report_not_comlete
			#/export/controller/controller.mail_send.pl mail_report_not_comlete $mail_email_addreses "Controller. Build detected. But testing not completed" "html"
			/export/controller/controller.mail_send.pl mail_report_not_comlete $mail_email_addreses "Controller. Functional tests. Debug. Build detected. But testing not completed" "html"
			rm -rf mail_report_not_comlete
		fi
	fi
fi
