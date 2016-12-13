cp -rf exports /etc/exports
killall -1 mountd
/etc/rc.d/rpcbind restart
/etc/rc.d/nfsd restart
/etc/rc.d/mountd restart
