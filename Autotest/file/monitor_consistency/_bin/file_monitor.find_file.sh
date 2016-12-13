#!/bin/sh
files=`ls $1 | grep md5s`
for file in $files
do
	count=`cat $1$file | grep -c $2`
	echo "file $1$file processing"
	if [ $count -gt 0 ]; then
		echo "file found "$file
		count_res=`cat $1$file | grep $2`
		echo "res found "$count_res
	fi
done