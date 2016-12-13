#!/bin/sh
echo "started controller.p4_sync.sh"
debug_status=`cat ../parameters.dat | grep debug_status | cut -f 2 -d =`
#p4 sync