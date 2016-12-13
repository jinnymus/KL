#!/bin/sh
testplan=`cat ../testplan.dat`
rm -rf ../import_testcases.log
for test in $testplan
do
	echo $test
	rm -rf logfileout
	rm -rf logfileerror
	exec 6>&1 7>&2
	exec 1> logfileout 2> logfileerror
	result=`/export/controller/controller.import_testcase.sh /export/ipm/client/$test/testcase.xml /export/ipm/client/$test`
	exec 1>&6 2>&7	
	echo "logfileout = " >> ../import_testcases.log
	cat logfileout >> ../import_testcases.log
	echo "logfileerror = " >> ../import_testcases.log
	cat logfileerror >> ../import_testcases.log
	echo $result >> ../import_testcases.log
	echo $result | grep '[DEBUG] Done'
	rm -rf logfileout
	rm -rf logfileerror		
done


