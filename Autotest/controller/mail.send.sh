#!/bin/sh
rm -rf mail_text
#echo '----------------' >> mail_text
echo 'From: <mailer@csn_autotest>' >> mail_text
echo 'To: <mailer@csn_autotest>' >> mail_text
echo 'Subject: '$2 >> mail_text
echo 'Mime-Version: 1.0' >> mail_text
if [ $3 = "multipart" ]; then
	echo 'Content-Type: multipart/mixed; boundary=unique-boundary-1' >> mail_text
	echo ''  >> mail_text
	echo ''  >> mail_text
	echo '--unique-boundary-1'  >> mail_text
	echo 'Content-Type: text/html; charset="windows-1251"'  >> mail_text
	echo 'Content-Transfer-Encoding: 8bit'  >> mail_text
	echo ''  >> mail_text
	echo ''  >> mail_text
	echo '<html>'  >> mail_text
	cat $1 | while read line
	do
		#line_final=$line'<br>'
		line_final=$line
		echo $line_final  >> mail_text
	done
	echo '</html>'  >> mail_text
	echo ''  >> mail_text
	echo '--unique-boundary-1'  >> mail_text	
	echo 'Content-Description: debug.log'  >> mail_text
	echo 'Content-Type: text/html; charset="windows-1251"; name="debug.log"'  >> mail_text
	echo 'Content-Transfer-Encoding: 8bit'  >> mail_text
	echo 'Content-Disposition: attachment; filename="debug.log"'  >> mail_text
	echo ''  >> mail_text
	echo ''  >> mail_text
	cat $4 | while read line
	do
		#line_final=$line'<br>'
		line_final=$line
		echo $line_final  >> mail_text
	done
	attaches=`ls ../mail`
	for file in $attaches
	do
		echo ''  >> mail_text
		echo '--unique-boundary-1'  >> mail_text	
		echo 'Content-Description: '$file  >> mail_text
		echo 'Content-Type: text/html; charset="windows-1251"; name="'$file'"'  >> mail_text
		echo 'Content-Transfer-Encoding: 8bit'  >> mail_text
		echo 'Content-Disposition: attachment; filename="'$file'"'  >> mail_text
		echo ''  >> mail_text
		echo ''  >> mail_text
		cat ../mail/$file | while read line
		do
			#line_final=$line'<br>'
			line_final=$line
			echo $line_final  >> mail_text
		done
	done
	echo ''  >> mail_text
	echo '--unique-boundary-1--'  >> mail_text	
	cat mail_text | sendmail -v $5
else
	echo 'Content-Type: text/html; charset="windows-1251"' >> mail_text
	echo 'Content-Transfer-Encoding: 8bit' >> mail_text
	echo ''  >> mail_text
	echo '<html>'  >> mail_text
	cat $1 | while read line
	do
		#line_final=$line'<br>'
		line_final=$line
		echo $line_final  >> mail_text
	done
	echo '</html>'  >> mail_text
	cat mail_text | sendmail -v $4
	echo $4
fi
#echo '----------------'  >> mail_text
#cat mail_text | sendmail -v jinnymus@gmail.com

#rm -rf mail_text