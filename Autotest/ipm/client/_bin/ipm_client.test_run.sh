#!/bin/sh
run_test() {
cd ../$2
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] ######################################################' >> ../$1
fi
echo 'Running test '$2
testname=`echo 'Test '$2`
ipm_server=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
ipm_test=`cat ../parameters.dat | grep ipm_test | cut -f 2 -d =`
timer_sleep=`cat ../parameters.dat | grep timer_sleep | cut -f 2 -d =`
response=`cat response | awk '{ if (NR==1) {print $0}}'`
mail_logs_include=`cat ../parameters.dat | grep mail_logs_include | cut -f 2 -d =`
log_tail_strings=`cat ../parameters.dat | grep log_tail_strings | cut -f 2 -d =`
log_name=`cat ../parameters.dat | grep log_name | cut -f 2 -d =`
if [ $debug_status = on ]; then
	echo '[DEBUG] '$testname' : Start' >> ../$1
fi
echo $testname' : Start' >> ../$1
echo '<tr><td><b>'$testname'</b>' >> ../mail_report
cp -rf content_info.xml ../_db/content_info2.xml
cp -rf geo_ip.xml ../_db/geo_ip2.xml
mv -f ../_db/content_info2.xml ../_db/content_info.xml
mv -f ../_db/geo_ip2.xml ../_db/geo_ip.xml
echo $testname' : Files was copied' >> ../$1
sleep $timer_sleep
#result=`/usr/local/csn/utils/ipm/ipm_test --request ipm_request.xml --host $ipm_server:443`

a=0

while [ $a -lt 10 ]; 
do 
	if [ $debug_status = on ]; then
		echo '[DEBUG] a = '$a >> ../$1
	fi
	result=`/usr/local/csn/utils/ipm/ipm_test --request ipm_request.xml --host $ipm_server:443`
	response_error=`echo $result | grep -c error`	
	response_error2=`echo $result | grep -c Error`
	if [ $response_error -ge 1 -o $response_error2 -ge 1 ]; then	
		a=`expr $a + 1`		
	else
		a=10;
	fi
done

if [ $debug_status = on ]; then
	echo '[DEBUG] ipm_test result = '$result >> ../$1
fi
links=`echo $result | cut -f 2 -d " "`
if [ $debug_status = on ]; then
	echo '[DEBUG] links = '$links >> ../$1
	echo '[DEBUG] response from file = '$response >> ../$1
fi
if [ $ipm_test = off ]; then
			echo 'result = '$result
			echo 'result = '$result >> ../$1
	if [ $debug_status = on ]; then
		echo '[DEBUG] result = '$result >> ../$1
	fi			
fi
if [ $ipm_test = on ]; then
	if [ $debug_status = on ]; then
		echo '[DEBUG] checking response = error' >> ../$1
		echo '[DEBUG] result = '$result >> ../$1
	fi
	response_error=`echo $result | grep -c error`	
	response_error2=`echo $result | grep -c Error`
	if [ $debug_status = on ]; then
		echo '[DEBUG] response_error = '$response_error >> ../$1
		echo '[DEBUG] response_error2 = '$response_error2 >> ../$1		
	fi		
	if [ "$response" = "error" ]; then
#########
# Checking if expected response is error
#########		
		response_errnum=`cat response | awk '{ if (NR==2) {print $0}}'`
		result_finish=`echo $result | awk -F "returned error " '{print $2}'`
		if [ $debug_status = on ]; then
			echo '[DEBUG] Expected response = Error code' >> ../$1
			echo '[DEBUG] ipm_test result [1] = '$result_finish >> ../$1
			echo '[DEBUG] response errnum from file = '$response_errnum >> ../$1
		fi
		if [ "$result_finish" = "$response_errnum" ]; then
			if [ $debug_status = on ]; then
				echo '[DEBUG] Expected response = Response. Error' >> ../$1
				echo '[DEBUG] '$testname' : OK' >> ../$1
			fi
				echo $testname' : OK' >> ../$1
				testspass=`expr $testspass + 1`
				echo '</td><td><font color="green"><b>Passed</b></font></td></tr>' >> ../mail_report
		else 
#########
# if expected response not contain error 
#########			
			if [ $debug_status = on ]; then
				echo '[DEBUG] Expected response != Response. Error' >> ../$1
				echo '[DEBUG] Error:' >> ../$1
				echo '[DEBUG] '$result >> ../$1
			fi
			echo '@@@@@@@@@@@@@@@Error:@@@@@@@@@@@@@@@@' >> ../$1
			echo $result >> ../$1
			echo '<br>Error text:<br>' >> ../mail_report	
			echo $result >> ../mail_report
			if [ $mail_logs_include = yes ]; then
				tail -$log_tail_strings ../_logs/$log_name >> ../_mail_attaches/$2.log		
			fi			
			echo '</td><td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report
			errorexist=`expr $errorexist + 1`
			testsfail=`expr $testsfail + 1`
			fail=1
		fi				
	elif [ $response_error -ge 1 -o $response_error2 -ge 1 ]; then	
#########
# Checking if response contain errors	
#########	
		if [ $debug_status = on ]; then
			echo '[DEBUG] @@@@@@@@@@@@@@@ Error detected @@@@@@@@@@@@@@@' >> ../$1
		fi
		if [ $debug_status = on ]; then
			echo '[DEBUG] Error text:' >> ../$1
			echo '[DEBUG] '$result >> ../$1
		fi
		echo '@@@@@@@@@@@@@@@Error:@@@@@@@@@@@@@@@@' >> ../$1
		echo $result >> ../$1
		echo '<br>Error text:<br>' >> ../mail_report	
		echo $result >> ../mail_report
		if [ $mail_logs_include = yes ]; then
				tail -$log_tail_strings ../_logs/$log_name >> ../_mail_attaches/$2.log		
		fi
		echo '</td><td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report		
		errorexist=`expr $errorexist + 1`
		testsfail=`expr $testsfail + 1`
		fail=1		
	else
#########
# other text response
#########	
		if [ $debug_status = on ]; then
			echo '[DEBUG] checking links -ne 0' >> ../$1
		fi
		if [ $links -ne "0" ]; then
#########
# if count of links at response != 0
#########			
			sep1=4
			sep2=6
			result_finish=`echo $result | cut -f $sep1 -d " "`' : '`echo $result | cut -f $sep2 -d " "`
			if [ $debug_status = on ]; then
				echo '[DEBUG] ipm_test result [1] = '$result_finish >> ../$1
			fi
			c=2
			while [ $c -le $links ]
				do
				sep1=`expr $sep1 + 3`
				sep2=`expr $sep2 + 3`
				result_add=`echo $result | cut -f $sep1 -d " "`' : '`echo $result | cut -f $sep2 -d " "`
				if [ $debug_status = on ]; then
					echo '[DEBUG] result_add = '$result_add >> ../$1
				fi
				result_finish=$result_finish' '$result_add
				if [ $debug_status = on ]; then
					echo '[DEBUG] result_finish = '$result_finish >> ../$1
					echo '[DEBUG] sep1 = '$sep1 >> ../$1
					echo '[DEBUG] sep2 = '$sep2 >> ../$1
					echo "[DEBUG] c = "$c >> ../$1					
					echo "[DEBUG] links = "$links >> ../$1					
				fi
				sep=`expr $sep+3`
				c=`expr $c + 1`
			done
		fi
		if [ $debug_status = on ]; then
			echo '[DEBUG] checking links -eq 0' >> ../$1
		fi			
		if [ $links -eq "0" ]; then
#########
# if count of links at response = 0
#########					
			if [ $debug_status = on ]; then
				echo '[DEBUG] Expected response from file = '$response >> ../$1
			fi
			if [ $debug_status = on ]; then
				echo '[DEBUG] Expected response = 0 Links' >> ../$1
				echo '[DEBUG] Response = 0' >> ../$1
			fi
			if [ "$response" = "0" ]; then
				if [ $debug_status = on ]; then
					echo '[DEBUG] Expected response = Response. 0' >> ../$1
					echo '[DEBUG] '$testname' : OK' >> ../$1
				fi
					echo $testname' : OK' >> ../$1
					echo '</td><td><font color="green"><b>Passed</b></font></td></tr>' >> ../mail_report					
					testspass=`expr $testspass + 1`
			else 
				if [ $debug_status = on ]; then
					echo '[DEBUG] Expected response != Response. 0' >> ../$1
					echo '[DEBUG] Error:' >> ../$1
					echo '[DEBUG] '$result >> ../$1
				fi
				echo '@@@@@@@@@@@@@@@Error:@@@@@@@@@@@@@@@@' >> ../$1
				echo $result >> ../$1
				echo '<br>Error text:<br>' >> ../mail_report	
				echo $result >> ../mail_report	
				if [ $mail_logs_include = yes ]; then
					tail -$log_tail_strings ../_logs/$log_name >> ../_mail_attaches/$2.log				
				fi
				echo '</td><td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report				
				errorexist=`expr $errorexist + 1`
				testsfail=`expr $testsfail + 1`
				fail=1
			fi
		else
#########
# if count of links at response != 0
#########			
			if [ $debug_status = on ]; then
				echo '[DEBUG] Expected response = Links' >> ../$1
			fi
			if [ "$result_finish" = "$response" ]; then
				if [ $debug_status = on ]; then
					echo '[DEBUG] Expected response = Response. Links' >> ../$1
					echo '[DEBUG] '$testname' : OK' >> ../$1
				fi
				echo $testname' : OK' >> ../$1
				echo '</td><td><font color="green"><b>Passed</b></font></td></tr>' >> ../mail_report				
				testspass=`expr $testspass + 1`
			else 
				if [ $debug_status = on ]; then
					echo '[DEBUG] Expected response != Response. Links' >> ../$1
					echo '[DEBUG] Error:' >> ../$1
					echo '[DEBUG] '$result >> ../$1
				fi
				echo '@@@@@@@@@@@@@@@Error:@@@@@@@@@@@@@@@@' >> ../$1
				echo $result >> ../$1
				echo '<br>Error text:<br>' >> ../mail_report	
				echo $result >> ../mail_report
				if [ $mail_logs_include = yes ]; then
					tail -$log_tail_strings ../_logs/$log_name >> ../_mail_attaches/$2.log			
				fi				
				echo '</td><td><font color="red"><b>Failed</b></font></td></tr>' >> ../mail_report				
				errorexist=`expr $errorexist + 1`
				testsfail=`expr $testsfail + 1`
				fail=1
			fi
		fi
	fi
fi	
if [ $debug_status = on ]; then
	echo '[DEBUG] '$testname' : End' >> ../$1
fi
echo $testname' : End' >> ../$1
echo '_____________________' >> ../$1
cd ../_bin
}