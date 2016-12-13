#!/bin/sh
# Sctipt for deleteting temp files
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
echo "started controller.delete_temporary_files.sh"
cd /export/distrib
rm -rf *.tgz
cd /export/distrib/csn_frontend
rm -rf *.tgz
cd /export/distrib/csn_frontend_dev
rm -rf *.tgz
cd /export/distrib/csn_frontend_exp
rm -rf *.tgz
cd /export/distrib/ipm_client
rm -rf *.tgz
if [ $debug_status = on ]; then
	echo '[DEBUG] Files in /export/distrib was deleted' >> /export/controller/$1
fi
cd /export/logs
rm -rf *
if [ $debug_status = on ]; then
	echo '[DEBUG] Log files in /export/logs was deleted' >> /export/controller/$1
fi
rm -rf /export/mail/*
if [ $debug_status = on ]; then
	echo '[DEBUG] Log files in /export/mail was deleted' >> /export/controller/$1
fi
rm -rf /export/finish.dat
if [ $debug_status = on ]; then
	echo '[DEBUG] File finish.dat was deleted' >> /export/controller/$1
fi
rm -rf /export/mail/mail_report
if [ $debug_status = on ]; then
	echo '[DEBUG] File mail_report was deleted' >> /export/controller/$1
fi
cd /export/controller

