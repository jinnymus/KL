#!/bin/sh
mail_email_addreses=`cat ../parameters.dat | grep mail_email_addreses | cut -f 2 -d =`
mail_email_addreses="kirill.kalistratov@company.com,kirill.kalistratov12234@company.com"
rm -rf mail_report_test
echo "All tests finished<br>" >> mail_report_test
echo "Call parameters:<br>" >> mail_report_test
echo "1 = http://csn.avp.ru/distributives/stable/csn-2.9.30-FreeBSD-8.2-RELEASE.tgz<br>" >> mail_report_test
echo "2 = http://csn.avp.ru/distributives/stable/csn-test_suite-1.0-FreeBSD-8.2-RELEASE.tgz<br>" >> mail_report_test
/export/controller/controller.mail_send.pl mail_report_test $mail_email_addreses "Controller. Test" "multipart" ../status.dat ../mail