#!/bin/sh
run_test() {
. ../_bin/ipm_client.change_config.sh
. ../testcase.Change_config.content_limit.equivalent/case.sh
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
fe_ip_address=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
run_change_config $1 'testcase.Change_config.content_limit.equivalent' 'ipm.conf' 'content_output_limit' '1000' 'case.sh' $fail
}
