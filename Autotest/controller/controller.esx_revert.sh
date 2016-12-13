#!/bin/sh
cd /export/controller
debug_status=`cat /export/parameters.dat | grep debug_status | cut -f 2 -d =`
esx_server=`cat /export/parameters.dat | grep esx_server | cut -f 2 -d =`
esx_datastore=`cat /export/parameters.dat | grep esx_datastore | cut -f 2 -d =`
tests=`cat /export/csn_services_testplan.dat`
echo '[DEBUG] debug_status = '$debug_status
echo '[DEBUG] esx_server = '$esx_server
echo '[DEBUG] esx_datastore = '$esx_datastore
echo '[DEBUG] tests = '$tests

#controller_pass="rjvyfnf718"
controller_pass="2MuYcGbF"
for test in $tests
do
	machine_count=`cat /export/esx_machines.dat | grep -c $test`
	idx=0
	while [ $idx -ne $machine_count ]
	do
		idx=`expr $idx + 1`
		#esx_machine=`cat ../esx_machines.dat | grep $test | awk '{{ if (NR=='$idx') print $0}}' | cut -f 2 -d =`
		esx_machine=`cat /export/esx_machines.dat | grep $test | awk '{{ if (NR=='$idx') print $0}}' | rev | cut -f 1 -d = | rev`
		if [ $debug_status = on ]; then
			echo '[DEBUG] For test '$test' datastore = '$esx_datastore >> $1
			echo '[DEBUG] For test '$test' esx_server = '$esx_server >> $1
			echo '[DEBUG] For test '$test' esx machine = '$esx_machine >> $1	
		fi
		echo 'For test '$test' esx machine = '$esx_machine
		echo 'For test '$test' esx machine = '$esx_machine >> $1	
		revert_result=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" revertsnapshot`
		if [ $debug_status = on ]; then
			echo '[DEBUG] revert_result = '$revert_result >> $1	
		fi
		revert=`echo $revert_result | cut -f 7 -d ' '`
		if [ $debug_status = on ]; then
			echo '[DEBUG] revert = '$revert >> $1	
		fi
		if [ "$revert" = "1" ]; then
			getstate_result=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" getstate`
			if [ $debug_status = on ]; then
				echo "[DEBUG] Sleep 30 seconds for getstate" >> $1
			fi
			sleep 10
			getstate=`echo $getstate_result | cut -f 6 -d ' '`
			if [ $debug_status = on ]; then
				echo '[DEBUG] getstate before revert = '$getstate >> $1	
			fi
			if [ $getstate = off ]; then
				if [ $debug_status = on ]; then
					echo '[DEBUG] machine is stopped. Trying to start' >> $1
				fi
				start_result=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" start`
				if [ $debug_status = on ]; then
					echo '[DEBUG] start result = '$getstate >> $1	
					echo "[DEBUG] Sleep 30 seconds for starting" >> $1	
				fi
				sleep 30
				getstate=`echo $start_result | cut -f 6 -d ' '`
				if [ $getstate = off ]; then
					echo "##############" >> $1
					echo "!!!!Cannot start start" >> $1
					break
				fi
			fi
			if [ $debug_status = on ]; then
				echo "[DEBUG] Sleep 30 seconds for reverting" >> $1	
			fi
			sleep 30
			getstate_result2=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" getstate`
			getstate2=`echo $getstate_result2 | cut -f 6 -d ' '`
			if [ $debug_status = on ]; then
				echo '[DEBUG] getstate after revert = '$getstate2 >> $1
			fi
			echo 'For test '$test' esx machine '$esx_machine' was reverted!' >> $1
			echo 'For test '$test' esx machine '$esx_machine' was reverted!'
		else
			echo '###############' >> $1
			echo '!!!!For test '$test' esx machine '$esx_machine' was not reverted!' >> $1
		fi
	done
done