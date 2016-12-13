#!/bin/sh
#rm -rf ../finish_new.dat
#debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
#tests=`cat ../csn_services_testplan.dat`
#finish_dat=`cat ../finish.dat`
#for line in $finish_dat
#do
#search_line=`echo $line | grep $1 | grep -c $2`
##echo 'line = '$line
#if [ $search_line -eq 1 ]; then
	#echo $1'='$3 >> ../finish_new.dat
#else echo $line >> ../finish_new.dat
#fi
#done
#mv ../finish_new.dat ../finish.dat
cat /export/finish.dat | sed 's/'$1'='$2'/'$1'='$3'/g' > /export/finish_new.dat
mv /export/finish_new.dat /export/finish.dat