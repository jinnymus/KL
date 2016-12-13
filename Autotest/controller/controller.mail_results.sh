#!/bin/sh
echo "started controller.mail_results.sh"
debug_status=`cat /export/parameters.dat | grep debug_status | cut -f 2 -d =`
mail_send_results=`cat /export/parameters.dat | grep mail_send_results | cut -f 2 -d =`
mail_send_debug=`cat /export/parameters.dat | grep mail_send_debug | cut -f 2 -d =`
mail_email_addreses=`cat /export/parameters.dat | grep mail_email_addreses | cut -f 2 -d =`
mail_logs_include=`cat /export/parameters.dat | grep mail_logs_include | cut -f 2 -d =`
debug_mail=`cat /export/parameters.dat | grep debug_mail | cut -f 2 -d =`
#cat $1 | while read line
#do
#	line_final=$line'<br>'
#	#line_final=$line
#	echo $line_final  >> mail_report
#done
rm -rf /export/controller/mail_report	
rm -rf /export/mail/mail_report	
echo "All tests finished<br>"  >> mail_report
echo "Call parameters:<br>" >> mail_report
echo "1 = "$2"<br>" >> mail_report
echo "2 = "$3"<br>" >> mail_report
if [ $mail_send_results = yes  ]; then
	if [ $debug_status = on ]; then
		echo '[DEBUG] Sending email notification report' >> /export/controller/$1
	fi
	mail_subject=`echo 'Controller - Functional tests`	
	if [ $mail_send_debug = yes ]; then
		if [ $debug_status = on ]; then	
			echo '[DEBUG] Sending debug log' >> /export/controller/$1	
		fi			
		echo '[DEBUG] mail_subject = '$mail_subject >> /export/controller/$1
		echo '[DEBUG] debug_mail = '$debug_mail >> /export/controller/$1
		echo '[DEBUG] mail_email_addreses_debug = '$mail_email_addreses_debug >> /export/controller/$1
		echo '[DEBUG] mail_email_addreses = '$mail_email_addreses >> /export/controller/$1
		if [ $mail_logs_include = yes ]; then
			mv /export/controller/$1 /export/logs 
			mv /export/logs/*.log /export/mail
		fi
		#./mail.send.sh mail_report $mail_email_addreses "$mail_subject" "multipart" /export/mail/$1
		if [ $debug_mail = on ]; then
			/export/controller/controller.mail_send.pl mail_report $mail_email_addreses "$mail_subject" "multipart" /export/mail/$1 /export/mail
		else
			/export/controller/controller.mail_send.pl mail_report $mail_email_addreses "$mail_subject" "multipart" /export/mail/$1 /export/mail
		fi
	else
		if [ $mail_logs_include = yes ]; then
			mv /export/controller/$1 /export/logs 
			mv /export/logs/*.log /export/mail
		fi
		#./mail.send.sh mail_report $mail_email_addreses "$mail_subject" "html"
		if [ $debug_mail = on ]; then
			/export/controller/controller.mail_send.pl mail_report $mail_email_addreses "$mail_subject" "html"			
		else
			/export/controller/controller.mail_send.pl mail_report $mail_email_addreses "$mail_subject" "html"
		fi
	fi
#	if [ $debug_status = on ]; then		
#		echo '[DEBUG] Notification report sended' >> $1	
#	fi		
fi
#rm -rf /export/controller/mail_report	
#rm -rf /export/mail/mail_report	