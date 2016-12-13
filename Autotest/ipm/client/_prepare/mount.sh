mkdir ../_db
ipm_server=`cat ../ipm_server.dat`
mount -t nfs $ipm_server:/usr/local/csn/db/ipm ../_db

