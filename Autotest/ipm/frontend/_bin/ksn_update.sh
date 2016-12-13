/usr/local/etc/rc.d/csn_frontend stop
sleep 3
cp -rf /export/ipm /usr/local/csn/bin
sleep 3
/usr/local/etc/rc.d/csn_frontend start
