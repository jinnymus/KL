#!/bin/sh
testplan=`cat ../testplan.dat`
for test in $testplan
do
	echo $test
	rm -rf ../$test/desc_new
	cat ../$test/desc | sed 's/</"/g' | sed 's/>/"/g' >> ../$test/desc_new
	mv ../$test/desc_new ../$test/desc
done


