#!/bin/sh
echo "started controller.p4_params.sh"
export P4PORT=pf.avp.ru:1666
export P4USER=Kalistratov
export P4PASSWD=Avr999avr999
export P4CLIENT controller_autotester_geoconf
export P4HOST controller_autotester
export P4ROOT=/export/perforce/controller_autotester_geoconf
echo "P4PORT = "$P4PORT
echo "P4USER = "$P4USER
echo "P4PASSWD = "$P4PASSWD
echo "P4CLIENT = "$P4CLIENT
echo "P4HOST = "$P4HOST
echo "P4ROOT = "$P4ROOT