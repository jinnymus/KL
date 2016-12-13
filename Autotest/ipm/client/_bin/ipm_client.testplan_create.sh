#!/bin/sh
testplandatetime=`date +%d.%m.%y_%T`
#cp -rf ../testplan.dat ../testplan_$testplandatetime.dat
rm -rf ../testplan.dat
ls ../ | grep testcase. >> ../testplan.dat