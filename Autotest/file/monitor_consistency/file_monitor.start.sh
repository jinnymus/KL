#!/bin/sh
status=`cat /file/status.dat | grep file_monitor | cut -f 2 -d =`
status_export=`cat /file/status_export.dat | grep file_monitor | cut -f 2 -d =`
proxy=`cat /file/parameters.dat | grep proxy | cut -f 2 -d =`
testdatetime=`date +%d.%m.%y_%T`
testdatetime_start=`date +%d.%m.%y_%T`
csn_log_name=`echo 'file_monitor_'$testdatetime'.log'`
debug_status=`cat /file/parameters.dat | grep debug_status | cut -f 2 -d =`
mail_email_addreses=`cat /file/parameters.dat | grep mail_email_addreses | cut -f 2 -d =`
mail_email_addr_debug=`cat /file/parameters.dat | grep mail_email_addr_debug | cut -f 2 -d =`
mail_email_addr_agregatelogs=`cat /file/parameters.dat | grep mail_email_addr_agregatelogs | cut -f 2 -d =`
mail_send_debug=`cat /file/parameters.dat | grep mail_send_debug | cut -f 2 -d =`
debug_status=`cat /file/parameters.dat | grep debug_status | cut -f 2 -d =`
debug_mail=`cat /file/parameters.dat | grep debug_mail | cut -f 2 -d =`
#testdatetime_for_agregate_folder=`date +%Y%m%d`;
echo "Start testing all "$testdatetime
#/usr/sbin/ntpdate moscow11.avp.ru
sleep 10
cd /file
echo "status = "$status
echo "status_export = "$status_export
if [ $status = Stopped ]; then
	mkdir logs
	mkdir mail
	mkdir _mail_attaches
	mkdir packet_files
	
	rm -rf /file/*core*
	rm -rf /file/*.log
	rm -rf /file/logs/*.log
	rm -rf /file/logs/*.gz
	cp -rf /export/clients/hips/hips_test /file/_bin
	#cp -rf /export/file/monitor_consistency/freetds.conf /usr/local/etc	
	exec 8>&1 9>&2
	exec 1> /file/logfileout_testing.log 2> /file/logfileerror_testing.log	
	if [ $debug_status = on ]; then
		echo "[DEBUG] status = "$status
		echo "[DEBUG] export proxy "$proxy
	fi
	echo "status = "$status >> /file/$csn_log_name
	echo "edit /file/status.dat" >> /file/$csn_log_name
	cat /file/status.dat | sed 's/file_monitor=Stopped/file_monitor=Running/g' > /file/status_new.dat
	mv /file/status_new.dat /file/status.dat
	echo "================================="  >> /file/$csn_log_name
	echo "Start testing all "$testdatetime >> /file/$csn_log_name
	echo "Start testing all "$testdatetime
	echo "================================="  >> /file/$csn_log_name
	echo "Start testing all "$testdatetime
	
	packet_folders_check=`ls /file/packet_files | grep -c packets`
	echo "packet_folders_check = "$packet_folders_check
	if [ $packet_folders_check -eq 0 ]; then
		echo "packet_folders_check change status export"
		cat /file/status_export.dat | sed 's/file_monitor=Yes/file_monitor=Not/g' > /file/status_export_new.dat
		mv /file/status_export_new.dat /file/status_export.dat		
	fi
	
	if [ $status_export = Not ]; then
		echo "Start export "$testdatetime >> /file/$csn_log_name
		echo "Start export "$testdatetime
		echo "status_export = Not"
		cat /file/status_export.dat | sed 's/file_monitor=Not/file_monitor=Yes/g' > /file/status_export_new.dat
		mv /file/status_export_new.dat /file/status_export.dat		
		rm -rf /file/packet_files/*
		/file/_bin/file_monitor.create_packets_folders.pl >> /file/$csn_log_name
		echo "edit /file/status_export.dat" >> /file/$csn_log_name
		#mkdir /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder
		#echo "get testdatetime_for_agregate_folder_past for Agregate logs" >> /file/$csn_log_name
		#testdatetime_for_agregate_folder_past=`expr $testdatetime_for_agregate_folder - 1`
		#echo "testdatetime_for_agregate_folder_past = "$testdatetime_for_agregate_folder_past		
		#echo "testdatetime_for_agregate_folder_past = "$testdatetime_for_agregate_folder_past  >> /file/$csn_log_name	
		#if [ -d /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past ]; then
		#		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" exist"
		#		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" exist"  >> /file/$csn_log_name
		#		cd /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past
		#		echo "create tar Agregate logs" >> /file/$csn_log_name
		#		tar -cvf $testdatetime_for_agregate_folder_past.tar *
		#		mv $testdatetime_for_agregate_folder_past.tar /export/storage/file_monitor_consistency/
		#		cd /export/storage/file_monitor_consistency/
		#		echo "delete past folder "$testdatetime_for_agregate_folder_past >> /file/$csn_log_name
		#		rm -rf $testdatetime_for_agregate_folder_past
		#		echo "create mail Agregate logs" >> /file/$csn_log_name
		#		echo "Agregate logs for "$testdatetime_for_agregate_folder_past"<br>" >> /file/results.html	
		#		echo '<br><a href="ftp://ftpduser:123@10.65.52.193/file_monitor_consistency/'$testdatetime_for_agregate_folder_past'.tar">Logs</a>' >> /file/results.html
		#		cp -rf /file/results.html /file/mail	
		#		echo "mail Agregate logs" >> /file/$csn_log_name
		#		/file/_bin/controller.mail_send.pl /file/results.html $mail_email_addr_agregatelogs "File. Monitoring test - Consistency. Debug info - Agregate logs" "multipart" /file/$csn_log_name /file/mail		
		#		cd /file				
		#else
		#		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" not exist"
		#		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" not exist"  >> /file/$csn_log_name
		#fi		
	fi	
	rm -rf /file/logs/*.log
	rm -rf /file/*.html
	rm -rf /file/_mail_attaches/*
	rm -rf /file/mail/*
	testdatetime_testing=`date +%d.%m.%y_%T`
	echo "Start testing "$testdatetime_testing	
	echo "Start testing  "$testdatetime_testing >> /file/$csn_log_name
	if [ $debug_status = on ]; then
		echo "[DEBUG] status = "$status
		echo "[DEBUG] export proxy "$proxy
	fi
	echo "export proxy "$proxy >> /file/$csn_log_name
	#setenv http_proxy $proxy
	export http_proxy=$proxy
	#setenv ftp_proxy $proxy
	export ftp_proxy=$proxy
	#if [ $debug_status = on ]; then
	#	echo "[DEBUG] start /file/_bin/file_monitor.file_servers_dat_create.sh"
	#	echo "[DEBUG] start /file/_bin/file_monitor.file_servers_dat_create.sh" >> /file/$csn_log_name
	#fi
	#echo "start /file/_bin/file_monitor.file_servers_dat_create.sh" >> /file/$csn_log_name
	#/file/_bin/file_monitor.file_servers_dat_create.pl
	#/file/_bin/file_monitor.file_servers_add_dat_create.pl
	#/file/_bin/file_monitor.file_servers_test_dat_create.pl
	#rm -rf /file/hostsdic.dat
	#/file/_bin/controller.hostsdic_create.pl /file /file/file_servers.dat /file/file_servers_hosts.dat	
	
	echo "start /export/controller/servers_dat/controller.servers_dat_dic_create.pl" >> /file/$csn_log_name
	/export/controller/servers_dat/controller.servers_dat_dic_create.pl /file file geo file_servers.dat servers_add.dat file_servers.dic hostsdic.dat
	
	echo "hostsdic.dat" >> /file/$csn_log_name
	echo "=============" >> /file/$csn_log_name
	cat /file/hostsdic.dat >> /file/$csn_log_name
	echo "=============" >> /file/$csn_log_name		
	#/file/_bin/file_monitor.file_servers_dic_create.pl

	
	echo "file_servers.dat:" >> /file/$csn_log_name
	cat /file/file_servers.dat >> /file/$csn_log_name
	echo "delete temp files" >> /file/$csn_log_name
	echo "start file_monitor.compare_server_to_publisher.pl" >> /file/$csn_log_name
	/file/_bin/file_monitor.compare_server_to_publisher2.pl
	testdatetime=`date +%d.%m.%y_%T`
	echo "================================="  >> /file/$csn_log_name
	echo "End testing start_tests "$testdatetime >> /file/$csn_log_name
	echo "================================="  >> /file/$csn_log_name
	echo "mail results"
	testdatetime=`date +%d.%m.%y_%T`
	echo "Start create results "$testdatetime
	echo "Start create results "$testdatetime >> /file/$csn_log_name	
	/file/_bin/file_monitor.analyze_results.pl "/file" "/file/logs" >> /file/$csn_log_name	
	/file/_bin/file_monitor.create_results.pl "/file" "/file/logs" 1000 "results" "normal" >> /file/$csn_log_name
	testdatetime=`date +%d.%m.%y_%T`	
	echo "End create results "$testdatetime
	echo "End create results "$testdatetime >> /file/$csn_log_name		
	#echo "file_analyzdebug_.log" >> /file/$csn_log_name		
	#cat /file/logs/file_analyzdebug_.log >> /file/$csn_log_name		
	echo "<br>" >> /file/results.html
	echo "Start test time "$testdatetime_start"<br>" >> /file/results.html
	testdatetime=`date +%d.%m.%y_%T`
	echo "End test time "$testdatetime"<br>" >> /file/results.html	
	cp -rf /file/results.html /file/mail	
	status_test_red=`cat /file/results.html | grep -c red`
	status_test_green=`cat /file/results.html | grep -c green`
	shanoeq_logs_count=`ls /file/logs/ | grep -c shanoeq`
	sqlfail_logs_count=`ls /file/logs/ | grep -c sqlfail`
	testdatetime_for_folder=`date +%Y%m%d%H%M`;
	echo '<br><a href="ftp://ftpduser:123@10.65.52.193/file_monitor_consistency/'$testdatetime_for_folder'.tar.gz">Logs</a>' >> /file/results.html
	echo '<br>Should be on FE, but there is not   -  file_fail_server_ip.log'  >> /file/results.html
	echo '<br>Failuries like: good<->bad		  -  file_fail_server_ip.log'  >> /file/results.html
	echo '<br>Should NOT be on FE, but exists     -  file_mustnotbutexist_server_ip.log'  >> /file/results.html
	echo "logfileerror_testing.log" >> /file/$csn_log_name
	cat /file/logfileerror_testing.log	>> /file/$csn_log_name
	cp -rf /file/logs/file_analyzeddic_.log /file/mail
	
	count_servers=`cat /file/results.html | grep "Servers count" | cut -f 4 -d ' '`
	echo "count_servers = "$count_servers
	echo "count_servers = "$count_servers >> /file/$csn_log_name
	
	if [ $count_servers -gt 0 ]; then
		if [ $debug_mail = on ]; then
			if [ $status_test_red -gt 0 ]; then
				#/file/_bin/controller.mail_send.pl /file/results.html $mail_email_addr_debug "File. Monitoring test - Consistency. Fail" "multipart" /file/$csn_log_name /file/mail
				/export/controller/controller.mail_send.pl /file/results.html $mail_email_addr_debug "File. Monitoring test - Consistency. Fail" "html"
			else
				if [ $status_test_green -gt 0 ]; then
					/export/controller/controller.mail_send.pl /file/results.html $mail_email_addr_debug "File. Monitoring test - Consistency. Pass" "html"
				else
					/export/controller/controller.mail_send.pl /file/results.html $mail_email_addr_debug "File. Monitoring test - Consistency. Fail" "html"
				fi		
			fi
		else
			if [ $status_test_red -gt 0 ]; then
				/export/controller/controller.mail_send.pl /file/results.html $mail_email_addreses "File. Monitoring test - Consistency. Fail" "html"
			else
				if [ $status_test_green -gt 0 ]; then
					/export/controller/controller.mail_send.pl /file/results.html $mail_email_addreses "File. Monitoring test - Consistency. Pass" "html"
				else
					/export/controller/controller.mail_send.pl /file/results.html $mail_email_addreses "File. Monitoring test - Consistency. Fail" "html"
				fi	
			fi
		fi	
	else
		/export/controller/controller.mail_send.pl /file/results.html $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - Servers count $count_servers" "multipart" /file/$csn_log_name /file/mail
	fi
	if [ $shanoeq_logs_count -gt 0 ]; then
		echo 'SHA no eq' >> /file/shanoeq.html
		/export/controller/controller.mail_send.pl /file/shanoeq.html $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - SHA no eq" "multipart" /file/$csn_log_name /file/mail
	fi
	#if [ $sqlfail_logs_count -gt 0 ]; then
		#echo 'SQL fail<br>' >> /file/sqlfail.html
		#tar -cvf sqlfail.tar *_sqlfail_*
		#sqlfiles=`ls /file/logs | grep sqlfail`
		#for file in $sqlfiles
		#do
		#	md5=`cat /file/logs/$file | grep md5_found_dublicate`
		#	echo "file = "$file" md5 = "$md5"<br>" >> /file/sqlfail.html
		#done
		#/export/controller/controller.mail_send.pl /file/sqlfail.html $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - SQL fail" "multipart" /file/$csn_log_name /file/mail
	#fi	
	sleep 3
	rm -rf /file/mail/results.html
	rm -rf /file/sqlfail.html
	exec 1>&8 2>&9
	cp -rf /file/logfileout_testing.log /file/_mail_attaches
	rm -rf /file/logfileout_testing.log
	cp -rf /file/logfileerror_testing.log /file/_mail_attaches	
	rm -rf /file/logfileerror_testing.log
	rm -rf /file/shanoeq.html
	echo "Mail debug log" >> /file/mail_testing
	if [ $mail_send_debug = on ]; then 
		/export/controller/controller.mail_send.pl /file/mail_testing $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - Log" "multipart" /file/$csn_log_name /file/_mail_attaches/*.log		
	fi
	rm -rf /file/mail_testing	
	cd /file
	echo "edit /file/status.dat" >> /file/$csn_log_name
	cat /file/status.dat | sed 's/file_monitor=Running/file_monitor=Stopped/g' > /file/status_new.dat
	mv /file/status_new.dat /file/status.dat	
	cd /file/logs
	
	#datetime_string=`date +%Y%m%d%H%M`;
	#fail_logs=`ls /file/logs/ | grep _fail_`
	#for file in $fail_logs
	#do
	#	cat /file/logs/$file >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#	echo "##################### hour = "$datetime_string" ##############################" >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#	
	#done
	#mustnotbutexist_logs=`ls /file/logs/ | grep _mustnotbutexist_`
	#for file in $mustnotbutexist_logs
	#do
	#	cat /file/logs/$file >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#	echo "##################### hour = "$datetime_string" ##############################" >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#done
	#sqlfail_logs=`ls /file/logs/ | grep _sqlfail_`
	#for file in $sqlfail_logs
	#do
	#	cat /file/logs/$file >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#	echo "##################### hour = "$datetime_string" ##############################" >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#done
	#shanoeq_logs=`ls /file/logs/ | grep _shanoeq_`
	#for file in $shanoeq_logs
	#do
	#	cat /file/logs/$file >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#	echo "##################### hour = "$datetime_string" ##############################" >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder/$file
	#done

	tar -czvf $testdatetime_for_folder.tar.gz *_fail_* *_mustnotbutexist_* *_md5dublicate_* *_verdictdublicate_* *_notdublicate_* *_filedublicate_* *_sqlfail_* *_errorlog_* *_debuglog_* *_shanoeq_* *_analyzeddic_* *_analyze_* *_analyzdebug_* *_analyzefull_* *_analyzefulldic_* *_debugerror_* /file/_mail_attaches/* /file/*.log
	mv $testdatetime_for_folder.tar.gz /export/storage/file_monitor_consistency
	echo "last_test="$testdatetime_for_folder > /export/tests/file_monitor_consistency.dat	
fi
testdatetime=`date +%d.%m.%y_%T`
echo "End testing all "$testdatetime