#!/bin/sh
run_case() {
	cd ../$2
	fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
	debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
	mail_logs_include=`cat ../parameters.dat | grep mail_logs_include | cut -f 2 -d =`
	log_tail_strings=`cat ../parameters.dat | grep log_tail_strings | cut -f 2 -d =`
	log_name=`cat ../parameters.dat | grep log_name | cut -f 2 -d =`	
	pass=0
	fail=0
	pwd=`pwd`
	if [ $debug_status = on ]; then
		echo '[DEBUG] pwd = '$pwd >> ../$1
		echo '[DEBUG] pwd = '$pwd
	fi	
	cp -rf content_info.xml ../_db/content_info2.xml
	cp -rf geo_ip.xml ../_db/geo_ip2.xml
	mv -f ../_db/content_info2.xml ../_db/content_info.xml
	mv -f ../_db/geo_ip2.xml ../_db/geo_ip.xml
	if [ $debug_status = on ]; then
		echo '[DEBUG] Files was copied' >> ../$1
		echo '[DEBUG] Files was copied'
	fi
	sleep 10
	ssh $fe_ip_address "date 201201011000"
	for i in 1 2 3 4 
	do
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
		
		res=`echo $result | grep -c 'testcase.ContentInfo.MaxDownloadCountPerDay'`
		if [ $res -ne 1 ]; then
			if [ $debug_status = on ]; then
				echo '[DEBUG] '$2' : Fail' >> ../$1
			fi		
			testsfail=`expr $testsfail + 1`
			errorexist=`expr $errorexist + 1`
			echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
			echo '<br>case failed<br>' >> ../mail_report
			echo '<br>First day 4 fail<br>' >> ../mail_report							
			echo '<br>result = '$result'<br>' >> ../mail_report
			if [ $mail_logs_include = yes ]; then
				cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
			fi			
			echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report			
			if [ $debug_status = on ]; then
				echo '[DEBUG] First day 4 fail' >> ../$1
				echo '[DEBUG] First day 4 fail'
				echo '[DEBUG] ipm_test result = '$result >> ../$1				
				echo '[DEBUG] ipm_test result = '$result								
			fi
			fail=1
			break
		fi
	done
	if [ $fail -ne 1 ]; then 
		ssh $fe_ip_address "date 201201011201"
		for i in 1 2 3 4 5 6
		do
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
			
			res=`echo $result | grep -c 'testcase.ContentInfo.MaxDownloadCountPerDay'`
			if [ $res -ne 1 ]; then
				if [ $debug_status = on ]; then
					echo '[DEBUG] '$2' : Fail' >> ../$1
				fi		
				testsfail=`expr $testsfail + 1`
				errorexist=`expr $errorexist + 1`
				echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
				echo '<br>case failed<br>' >> ../mail_report
				echo '<br>First day 6 fail<br>' >> ../mail_report							
				echo '<br>result = '$result'<br>' >> ../mail_report
				if [ $mail_logs_include = yes ]; then
					cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
				fi			
				echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report			
				if [ $debug_status = on ]; then
					echo '[DEBUG] First day 6 fail' >> ../$1
					echo '[DEBUG] First day 6 fail'
					echo '[DEBUG] ipm_test result = '$result >> ../$1				
					echo '[DEBUG] ipm_test result = '$result								
				fi
				fail=1
				break
			fi
		done
		if [ $fail -ne 1 ]; then 
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
			
			res=`echo $result | grep -c 'Ask later'`
			if [ $res -eq 1 ]; then
				if [ $debug_status = on ]; then
						echo '[DEBUG] first day pass' >> ../$1
						echo '[DEBUG] first day pass'
					fi		
				ssh $fe_ip_address "date 201201021001"
				for i in 1 2 3 4
				do
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
					
					res=`echo $result | grep -c 'testcase.ContentInfo.MaxDownloadCountPerDay'`
					if [ $res -ne 1 ]; then
						if [ $debug_status = on ]; then
							echo '[DEBUG] '$2' : Fail' >> ../$1
						fi		
						testsfail=`expr $testsfail + 1`
						errorexist=`expr $errorexist + 1`
						echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
						echo '<br>case failed<br>' >> ../mail_report
						echo '<br>second day 4 fail<br>' >> ../mail_report				
						echo '<br>result = '$result'<br>' >> ../mail_report
						if [ $mail_logs_include = yes ]; then
							cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
						fi			
						echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report	
						if [ $debug_status = on ]; then
							echo '[DEBUG] second day 4 fail' >> ../$1
							echo '[DEBUG] second day 4 fail'
							echo '[DEBUG] ipm_test result = '$result >> ../$1				
							echo '[DEBUG] ipm_test result = '$result						
						fi				
						fail=1
						break
					fi
				done
				if [ $fail -ne 1 ]; then 
					ssh $fe_ip_address "date 201201021101"		
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
					
					res=`echo $result | grep -c 'Ask later'`
					if [ $res -eq 1 ]; then		
						ssh $fe_ip_address "date 201201021202"
						for i in 1 2 3 4 5 6
						do
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
							
							res=`echo $result | grep -c 'testcase.ContentInfo.MaxDownloadCountPerDay'`
							if [ $res -ne 1 ]; then
								if [ $debug_status = on ]; then
									echo '[DEBUG] '$2' : Fail' >> ../$1
								fi		
								testsfail=`expr $testsfail + 1`
								errorexist=`expr $errorexist + 1`
								echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
								echo '<br>case failed<br>' >> ../mail_report
								echo '<br>second day 6 fail<br>' >> ../mail_report				
								echo '<br>result = '$result'<br>' >> ../mail_report
								if [ $mail_logs_include = yes ]; then
									cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
								fi			
								echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report	
								if [ $debug_status = on ]; then
									echo '[DEBUG] second day 6 fail' >> ../$1
									echo '[DEBUG] second day 6 fail'
									echo '[DEBUG] ipm_test result = '$result >> ../$1				
									echo '[DEBUG] ipm_test result = '$result						
								fi				
								fail=1
								break
							fi
						done		
						if [ $fail -ne 1 ]; then 						
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
							
							res=`echo $result | grep -c 'Ask later'`
							if [ $res -eq 1 ]; then
								pass=1
								testspass=`expr $testspass + 1`			
								echo '<tr><td><b>Test '$2' </b></td><td><font color="green"><b>Passed</b></font><br></td></tr>' >> ../mail_report				
								if [ $debug_status = on ]; then
									echo '[DEBUG] second day pass' >> ../$1
									echo '[DEBUG] second day pass'
								fi				
							else
								if [ $debug_status = on ]; then
									echo '[DEBUG] '$2' : Fail' >> ../$1
								fi		
								testsfail=`expr $testsfail + 1`
								errorexist=`expr $errorexist + 1`
								echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
								echo '<br>case failed<br>' >> ../mail_report
								echo '<br>second day 7 fail<br>' >> ../mail_report							
								echo '<br>result = '$result'<br>' >> ../mail_report
								if [ $mail_logs_include = yes ]; then
									cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
								fi			
								echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report				
								if [ $debug_status = on ]; then
									echo '[DEBUG] second day 7 fail' >> ../$1
									echo '[DEBUG] second day 7 fail'
									echo '[DEBUG] ipm_test result = '$result >> ../$1				
									echo '[DEBUG] ipm_test result = '$result					
								fi			
								fail=1
								break
							fi
						fi
					else
						if [ $debug_status = on ]; then
							echo '[DEBUG] '$2' : Fail' >> ../$1
						fi		
						testsfail=`expr $testsfail + 1`
						errorexist=`expr $errorexist + 1`
						echo '<tr><td><b>Test '$2': </b><br>' >> ../mail_report
						echo '<br>case failed<br>' >> ../mail_report
						echo '<br>second day check fail<br>' >> ../mail_report							
						echo '<br>result = '$result'<br>' >> ../mail_report
						if [ $mail_logs_include = yes ]; then
							cat ../_logs/$log_name | grep ContentDownloadCounter | tail -$log_tail_strings >> ../_mail_attaches/$2.log
						fi			
						echo '</td><td><font color="red"><b>Failed</b></font><br></td></tr>' >> ../mail_report				
						if [ $debug_status = on ]; then
							echo '[DEBUG] second day check fail' >> ../$1
							echo '[DEBUG] second day check fail'
							echo '[DEBUG] ipm_test result = '$result >> ../$1				
							echo '[DEBUG] ipm_test result = '$result					
						fi			
						fail=1
						break
					fi		
				fi
			else
				if [ $debug_status = on ]; then
					echo '[DEBUG] First day 11 fail' >> ../$1
					echo '[DEBUG] First day 11 fail'
					echo '[DEBUG] ipm_test result = '$result >> ../$1				
					echo '[DEBUG] ipm_test result = '$result				
				fi	
				fail=1
				break
			fi
		fi
	fi
	cd ../_bin
}