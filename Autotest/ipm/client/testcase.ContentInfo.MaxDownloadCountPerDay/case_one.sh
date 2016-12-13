#!/bin/sh
#run_case() {
	fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
	debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
	pass=0
	fail=0
	debug="on"
	cp -rf content_info.xml ../_db/content_info2.xml
	cp -rf geo_ip.xml ../_db/geo_ip2.xml
	mv -f ../_db/content_info2.xml ../_db/content_info.xml
	mv -f ../_db/geo_ip2.xml ../_db/geo_ip.xml
	if [ $debug_status = on ]; then
		echo '[DEBUG] Files was copied'
	fi
	#result=`/usr/local/csn/utils/ipm/ipm_test --request ipm_request.xml --host $fe_ip_address:443`

	a=0
	while [ $a -lt 10 ]; 
	do 
		if [ $debug_status = on ]; then
			echo '[DEBUG] a = '$a >> ../$1
		fi
		result=`/usr/local/csn/utils/ipm/ipm_test --request ipm_request.xml --host $fe_ip_address:443`
		response_error=`echo $result | grep -c error`	
		response_error2=`echo $result | grep -c Error`
		if [ $response_error -ge 1 -o $response_error2 -ge 1 ]; then	
			a=`expr $a + 1`		
		else
			a=10
		fi
	done		
	
	if [ $debug_status = on ]; then
		echo '[DEBUG] ipm_test result = '$result
	fi
#}