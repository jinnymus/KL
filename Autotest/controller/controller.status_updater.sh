#!/bin/sh
echo "started controller.status_updater.sh"
tests=`cat ../csn_services_testplan.dat`
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
cd ../
for test in $tests
do
	cd $test
	if [ $debug_status = on ]; then
		echo '[DEBUG] testname = "'$test'"' >> /export/controller/$1
	fi	
	rm -rf status.dat
	if [ $test = url ]; then
		if [ $debug_status = on ]; then
			echo '[DEBUG] testname url = "'$test'"' >> /export/controller/$1
		fi		
		echo 'frontend=Stopped' >> status.dat
		echo 'client_online=Stopped' >> status.dat
		echo 'client_offline=Stopped' >> status.dat
		echo 'fe_reboot=no' >> status.dat
	else
		if [ $debug_status = on ]; then
			echo '[DEBUG] testname not url = "'$test'"' >> /export/controller/$1
		fi			
		echo 'frontend=Stopped' >> status.dat
		echo 'client=Stopped' >> status.dat
		echo 'fe_reboot=no' >> status.dat		
	fi
	cd ../
done
cd controller
if [ $debug_status = on ]; then
	echo '[DEBUG] Status files updated' >> /export/controller/$1
fi