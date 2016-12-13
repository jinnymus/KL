#!/bin/sh
cd /file
cp -rf /export/clients/hips/hips_test /file/_bin
mail_email_addr_debug=`cat /file/parameters.dat | grep mail_email_addr_debug | cut -f 2 -d =`
mail_email_addr_agregatelogs=`cat /file/parameters.dat | grep mail_email_addr_agregatelogs | cut -f 2 -d =`
testdatetime=`date +%d.%m.%y_%T`
testdatetime_for_agregate_folder=`date +%Y%m%d`
echo "testdatetime = "$testdatetime
echo "testdatetime_for_agregate_folder = "$testdatetime_for_agregate_folder
csn_log_name=`echo 'file_monitor_agregatelog_'$testdatetime'.log'`
echo "csn_log_name = "$csn_log_name >> /file/$csn_log_name
#mkdir /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder
echo "get testdatetime_for_agregate_folder_past for Agregate logs" >> /file/$csn_log_name
testdatetime_for_agregate_folder_past=`expr $testdatetime_for_agregate_folder - 1`
echo "testdatetime_for_agregate_folder_past = "$testdatetime_for_agregate_folder_past		
echo "testdatetime_for_agregate_folder_past = "$testdatetime_for_agregate_folder_past  >> /file/$csn_log_name	
echo "mail_email_addr_debug = "$mail_email_addr_debug  >> /file/$csn_log_name	
echo "mail_email_addr_debug = "$mail_email_addr_debug
if [ -f /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past.tar.gz ]; then
	echo "file tar.gz exist. remove it"  >> /file/$csn_log_name	
	rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past.tar.gz
fi
echo "remove testdatetime_for_agregate_folder_past folder = "$testdatetime_for_agregate_folder_past  >> /file/$csn_log_name	
rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/
rm -rf /file/*agregatelog*.log
mkdir /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past
if [ -d /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past ]; then
		echo "files /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" exist"
		echo "files /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" exist"  >> /file/$csn_log_name
		cd /export/storage/file_monitor_consistency
		files=`ls | grep $testdatetime_for_agregate_folder_past | grep tar` 
		mkdir /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work

		for file in $files
		do
			echo "file tarlog = "$file
			echo "file tarlog = "$file  >> /file/$csn_log_name
			cp /export/storage/file_monitor_consistency/$file /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past
		done
		cd /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past
		echo "pwd"
		pwd
		files_tar=`ls | grep tar`
		files_count=`ls | grep -c tar`
		echo "files_count = "$files_count
		echo "files_count = "$files_count  >> /file/$csn_log_name		
		packetsize=`/export/controller/controller.math.pl x 10000 $files_count`
		echo "packetsize = "$packetsize
		echo "packetsize = "$packetsize  >> /file/$csn_log_name
		for file_tar in $files_tar
		do
			echo "file_tar = "$file_tar
			echo "file_tar = "$file_tar  >> /file/$csn_log_name
			tar -xzvf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/$file_tar
			files_log=`ls | grep log`
			for file_log in $files_log
			do
				debug_file=`echo $file_log | grep -c debuglog`
				#echo "debug_file = "$debug_file
				if [ $debug_file -eq 1 ]; then
					#echo "debuglog detected"
					rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/$file_log
				else
					echo "file_log = "$file_log
					echo "file_log = "$file_log  >> /file/$csn_log_name
					echo "################# date "$testdatetime_for_agregate_folder_past" file_tar "$file_tar" #####################" >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work/$file_log
					cat /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/$file_log >> /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work/$file_log
					rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/$file_log
				fi
			done
			rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/$file_tar
		done
		cd /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work
		
		echo "start /export/controller/servers_dat/controller.servers_dat_dic_create.pl" >> /file/$csn_log_name
		/export/controller/servers_dat/controller.servers_dat_dic_create.pl /file file geo file_servers.dat servers_add.dat file_servers.dic hostsdic.dat
	
		echo "start file_monitor.create_agregated_requests.pl" >> /file/$csn_log_name
		/file/_bin/file_monitor.create_agregated_requests.pl "/file" "/export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work"
	
		echo "start file_monitor.compare_server_to_publisher.pl" >> /file/$csn_log_name
		/file/_bin/file_monitor.compare_server_to_publisher2.pl "agregate" "/export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work"
		
		echo "create results file for agregate logs"  >> /file/$csn_log_name
		/file/_bin/file_monitor.analyze_results.pl "/file" "/export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work" >> /file/$csn_log_name
		cp -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work/file_analyzdebug_.log /file/mail
		cp -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work/file_analyzeddic_.log /file/mail		
		/file/_bin/file_monitor.create_results.pl "/file" "/export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past/work" $packetsize "results_agregate" "agregate" >> /file/$csn_log_name
		echo "create tar.gz agregate logs"  >> /file/$csn_log_name
		tar -czvf $testdatetime_for_agregate_folder_past.tar.gz *
		echo "tar.gz agregate logs created"  >> /file/$csn_log_name
		ls  >> /file/$csn_log_name
		mv $testdatetime_for_agregate_folder_past.tar.gz /export/storage/file_monitor_consistency
		cd /export/storage/file_monitor_consistency
		echo "remove work folder for agregate logs $testdatetime_for_agregate_folder_past"  >> /file/$csn_log_name
		rm -rf /export/storage/file_monitor_consistency/$testdatetime_for_agregate_folder_past	/	
else
		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" not exist"
		echo "folder /export/storage/file_monitor_consistency/"$testdatetime_for_agregate_folder_past" not exist"  >> /file/$csn_log_name
fi
cd /file
echo "create mail Agregate logs" >> /file/$csn_log_name
echo "<br>Agregate logs for "$testdatetime_for_agregate_folder_past"<br>" >> /file/results_agregate.html	
echo '<br><a href="ftp://ftpduser:123@10.65.67.128/file_monitor_consistency/'$testdatetime_for_agregate_folder_past'.tar.gz">Logs</a>' >> /file/results_agregate.html
echo "mail Agregate logs" >> /file/$csn_log_name
cp -rf /file/results_agregate.html /file/mail	
cp -rf /file/$csn_log_name /file/mail/debug.log
	
count_servers=`cat /file/results_agregate.html | grep "Servers count" | cut -f 4 -d ' '`
echo "count_servers = "$count_servers
echo "count_servers = "$count_servers >> /file/$csn_log_name

if [ $count_servers -gt 0 ]; then
	/file/_bin/controller.mail_send.pl /file/results_agregate.html $mail_email_addr_agregatelogs "File. Monitoring test - Consistency. Debug info - Agregate logs" "html"
else
	/file/_bin/controller.mail_send.pl /file/results_agregate.html $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - Agregate logs - Servers count $count_servers" "multipart" /file/$csn_log_name /file/mail
	#/file/_bin/controller.mail_send.pl /file/results_agregate.html $mail_email_addr_debug "File. Monitoring test - Consistency. Debug info - Agregate logs - Servers count $count_servers" "html"
fi	
rm /file/results_agregate.html
rm /file/$csn_log_name