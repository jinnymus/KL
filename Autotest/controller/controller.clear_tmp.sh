#!/bin/sh
jails=`ls /jail | grep jail_`
for jail in $jails
do
	echo $jail
	du -h -d 0 /jail/$jail/tmp
	rm -rf /jail/$jail/tmp
done