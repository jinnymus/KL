#!/bin/sh
/export/controller/controller.geo2zabbix.pl 2>&1 > /export/logs/geo2zabbix.log
/export/controller/controller.geo2zabbix_import.pl items no 2>&1 >> /export/logs/geo2zabbix.log
/export/controller/controller.geo2zabbix_import.pl graphs no 2>&1 >> /export/logs/geo2zabbix.log 
/export/controller/controller.geo2zabbix_import.pl templates no 2>&1 >> /export/logs/geo2zabbix.log 
/export/controller/controller.geo2zabbix_import.pl hosts no 2>&1 >> /export/logs/geo2zabbix.log 
/export/controller/controller.geo2zabbix_import.pl screens no 2>&1 >> /export/logs/geo2zabbix.log 
