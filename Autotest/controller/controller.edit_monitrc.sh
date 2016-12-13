#!/bin/sh
echo "Controller.edit_monitrc.sh"
set alert csn-devs@company.com on {nonexist}
cat /usr/local/etc/monitrc | sed 's/set alert csn-devs@company.com on {nonexist}/set alert dummy@out on {nonexist}/g' > /usr/local/etc/monitrc_new
mv /usr/local/etc/monitrc_new /usr/local/etc/monitrc
chmod 700 /usr/local/etc/monitrc