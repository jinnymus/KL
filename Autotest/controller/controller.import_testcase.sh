#!/bin/sh
echo "started controller.import_testcase.sh"
/usr/local/bin/java -Xms512m -Xmx512m -jar /export/controller/import_testcase.jar $1 $2 http://10.65.40.178:8080/tfs KSN.Transport kl kalistratov Y6UHYziG
