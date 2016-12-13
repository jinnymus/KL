#!/bin/sh
echo "started controller.download.sh"
echo $wget_csn
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
package_url=`cat /export/parameters.dat | grep package_url | cut -f 2 -d =`
linktype=`echo $1`
file=`echo $2 | rev | cut -f 1 -d / | rev`
if [ $debug_status = on ]; then
	echo '[DEBUG] linktype = '$linktype >> $3
	echo '[DEBUG] file = '$file >> $3
fi
cd /export/distrib
if [ "$linktype" = "ipm_client" ]; then
	if [ $debug_status = on ]; then
		echo '[DEBUG] linktype is ipm_client = '$linktype >> ../controller/$3
	fi
	
	exec 6>&1 7>&2
	exec 1> logfileout_download 2> logfileerror_download
	wget $2
	echo "code = "$? >> ../controller/$3
	exec 1>&6 2>&7
#	wget -o /dev/null $2
	mv $file /export/distrib/ipm_client/$file
	if [ $debug_status = on ]; then	
		#echo '[DEBUG] logfileout_download = ' >> ../controller/$3		
		#cat logfileout_download >> ../controller/$3		
		#echo '[DEBUG] logfileerror_download = ' >> ../controller/$3		
		#cat logfileerror_download >> ../controller/$3		
		echo '[DEBUG] Download ipm_client.tgz complete' >> ../controller/$3	
	fi
	echo 'Download ipm_client.tgz complete'
	exec 6>&1 7>&2
	exec 1> logfileout_download2 2> logfileerror_download2	
#	wget -o /dev/null http://csn.avp.ru/distributives/urlrep.tgz
	wget http://csn.avp.ru/distributives/urlrep.tgz
	echo "code = "$? >> ../controller/$3	
	exec 1>&6 2>&7
	if [ $debug_status = on ]; then		
		#echo '[DEBUG] logfileout_download2 = ' >> ../controller/$3		
		#cat logfileout_download2 >> ../controller/$3		
		#echo '[DEBUG] logfileerror_download2 = ' >> ../controller/$3		
		#cat logfileerror_download2 >> ../controller/$3	
		echo '[DEBUG] Download urlrep.tgz complete' >> ../controller/$3
	fi
elif [ "$linktype" = "csn" ]; then
	if [ $debug_status = on ]; then
		echo '[DEBUG] linktype is csn = '$linktype >> ../controller/$3
	fi
#	wget -o /dev/null http://csn.avp.ru/distributives/dev/csn-FreeBSD-8.2-RELEASE.tgz
	if [ $package_url = stable ]; then
		exec 6>&1 7>&2
		exec 1> logfileout_download3 2> logfileerror_download3	
		wget $2
		echo "code = "$? >> ../controller/$3	
	#	wget -o /dev/null $2
		exec 1>&6 2>&7
		mv $file /export/distrib/csn_frontend/$file
		if [ $debug_status = on ]; then		
			#echo '[DEBUG] logfileout_download3 = ' >> ../controller/$3		
			#cat logfileout_download3 >> ../controller/$3		
			#echo '[DEBUG] logfileerror_download3 = ' >> ../controller/$3		
			#cat logfileerror_download3 >> ../controller/$3	
			echo '[DEBUG] Download csn.tgz complete' >> ../controller/$3
		fi
		echo 'Download csn.tgz complete'
		exec 6>&1 7>&2
		exec 1> logfileout_download4 2> logfileerror_download4	
		wget http://csn.avp.ru/distributives/dev/csn-dev-FreeBSD-8.2-RELEASE.tgz	
		exec 1>&6 2>&7	
		mv csn-dev-FreeBSD-8.2-RELEASE.tgz /export/distrib/csn_frontend_dev
		echo "code = "$? >> ../controller/$3
	else
		exec 6>&1 7>&2
		exec 1> logfileout_download3 2> logfileerror_download3	
		wget $package_url
		echo "code = "$? >> ../controller/$3	
		exec 1>&6 2>&7
		package_file=`echo $package_url | rev | cut -f 1 -d '/' | rev`
		mv $package_file /export/distrib/csn_frontend_exp/$package_file
	fi
	if [ $debug_status = on ]; then		
		#echo '[DEBUG] logfileout_download4 = ' >> ../controller/$3		
		#cat logfileout_download4 >> ../controller/$3		
		#echo '[DEBUG] logfileerror_download4 = ' >> ../controller/$3		
		#cat logfileerror_download4 >> ../controller/$3			
		echo '[DEBUG] Download csn-FreeBSD-8.2-RELEASE.tgz complete' >> ../controller/$3
	fi
fi
cd /export/controller
