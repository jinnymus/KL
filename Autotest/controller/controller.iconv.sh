#!/bin/sh
echo "started iconv.sh"
LIST=`cat testplan.dat`
for i in $LIST
do 
	iconv -f CP1251 -t UTF-8 $i/desc >> $i/desc_new
	mv $i/desc_new $i/desc
done