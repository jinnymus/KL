exec 6>&1 7>&2
exec 1> logfileout 2> logfileerror
nc -z 172.16.134.59 443
exec 1>&6 2>&7