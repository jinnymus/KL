#!/bin/sh
cd /export/controller
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
esx_server=`cat ../parameters.dat | grep esx_server | cut -f 2 -d =`
esx_datastore=`cat ../parameters.dat | grep esx_datastore | cut -f 2 -d =`
tests=`cat ../csn_services_testplan.dat`
#controller_pass="rjvyfnf718"
controller_pass="2MuYcGbF"
for test in $tests
do
	machine_count=`cat ../esx_machines.dat | grep -c $test`
	idx=0
	while [ $idx -ne $machine_count ]
	do
		idx=`expr $idx + 1`
		#esx_machine=`cat ../esx_machines.dat | grep $test | awk '{{ if (NR=='$idx') print $0}}' | cut -f 2 -d =`
		esx_machine=`cat ../esx_machines.dat | grep $test | awk '{{ if (NR=='$idx') print $0}}' | rev | cut -f 1 -d = | rev`
		if [ $debug_status = on ]; then
			echo '[DEBUG] For test '$test' datastore = '$esx_datastore >> $1
			echo '[DEBUG] For test '$test' esx_server = '$esx_server >> $1
			echo '[DEBUG] For test '$test' esx machine = '$esx_machine >> $1	
		fi
		echo 'For test '$test' esx machine = '$esx_machine
		echo 'For test '$test' esx machine = '$esx_machine >> $1	
		stop_result=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" stop hard`
		if [ $debug_status = on ]; then
			echo '[DEBUG] stop_result = '$stop_result >> $1	
		fi
		stop=`echo $stop_result | cut -f 6 -d ' '`
		if [ $debug_status = on ]; then
			echo '[DEBUG] stop = '$stop >> $1	
		fi
		if [ "$stop" = "1" ]; then
			getstate_result=`vmware-cmd -v -U root -P $controller_pass -H $esx_server "$esx_machine" getstate`
			if [ $debug_status = on ]; then
				echo "[DEBUG] Sleep 30 seconds for getstate" >> $1
			fi
			sleep 10
			getstate=`echo $getstate_result | cut -f 6 -d ' '`
			if [ $debug_status = on ]; then
				echo '[DEBUG] getstate = '$getstate >> $1	
			fi
			echo 'For test '$test' esx machine '$esx_machine' was stopped!' >> $1
			echo 'For test '$test' esx machine '$esx_machine' was stopped!'
		else
			echo '###############' >> $1
			echo '!!!!For test '$test' esx machine '$esx_machine' was not stopped!' >> $1
		fi
	done
done