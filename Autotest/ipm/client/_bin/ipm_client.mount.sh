umount ../_db
umount ../_logs
rm -rf ../_db
rm -rf ../_logs
mkdir ../_db
mkdir ../_logs
ipm_server=`cat /export/ipm/frontend/parameters.dat | grep fe_ip_address | cut -f 2 -d =`
echo $ipm_server
mount -t nfs $ipm_server:/usr/local/csn/db/ipm ../_db
mount -t nfs $ipm_server:/usr/local/csn/log ../_logs

