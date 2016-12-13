#!/bin/sh
echo "started controller.finish_dat_create.sh"
debug_status=`cat /export/parameters.dat | grep debug_status | cut -f 2 -d =`
tests=`cat /export/csn_services_testplan.dat`
for test in $tests
do
echo $test'=Running' >> /export/finish.dat
if [ $debug_status = on ]; then
	echo '[DEBUG] File finish.dat was created' >> $1
fi
done