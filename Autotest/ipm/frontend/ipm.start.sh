#!/bin/sh
testing=`cat /export/ipm/frontend/parameters.dat | grep testing | cut -f 2 -d =`
mail_email_addreses_all=`cat /export/ipm/frontend/parameters.dat | grep mail_email_addreses_all | cut -f 2 -d =`
mail_email_addreses_debug=`cat /export/ipm/frontend/parameters.dat | grep mail_email_addreses_debug | cut -f 2 -d =`
debug_mail=`cat /export/ipm/frontend/parameters.dat | grep debug_mail | cut -f 2 -d =`
fe_reboot=`cat /export/ipm/status.dat | grep fe_reboot | cut -f 2 -d =`
log_name=`cat /export/ipm/frontend/parameters.dat | grep log_name | cut -f 2 -d =`
/usr/sbin/ntpdate moscow11.avp.ru
sleep 10
if [ $testing = on ]; then
	ip_fe=`ifconfig | grep inet | head -1 | cut -f 2 -d " "`
	fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
	cat /export/ipm/frontend/parameters.dat | sed 's/fe_ip_address='$fe_ip_address'/fe_ip_address='$ip_fe'/g' >> /export/ipm/frontend/parameters_new.dat
	mv /export/ipm/frontend/parameters_new.dat /export/ipm/frontend/parameters.dat
	if [ $fe_reboot = no ]; then
		rm -rf *.log
		rm -rf /export/ipm/frontend/*.log
	fi
	if [ $fe_reboot = yes ]; then
		echo 'Starting OS 0...' >> /export/ipm/frontend/$log_name
	fi	
	cd /export/ipm/frontend
	#exec 4>&1 5>&2
	#exec 1> log 2> log
	./_bin/ipm_frontend.testplan_create.sh
	./_bin/ipm_frontend.start_tests.sh
	#exec 1>&4 2>&5
else
	cd /export/ipm/frontend/_bin
	echo "Testing off"
	echo "<b>Testing off</b><br>" >> mail_report_testing_off
	/export/controller/controller.mail_send.pl mail_report_testing_off $mail_email_addreses_debug "IPM. Functional test - Frontend. Debug info - No testing" "html"
	rm -rf mail_report_testing_off
fi