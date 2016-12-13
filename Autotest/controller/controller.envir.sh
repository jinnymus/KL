#!/bin/csh
#setenv EDITOR ee
#export EDITOR=ee
set proxy = `/bin/sh cat /export/parameters.dat | grep proxy | cut -f 2 -d =`
#echo "proxy envir = "$proxy 
#setenv http_proxy $proxy
#setenv ftp_proxy $proxy
#export http_proxy=$proxy
#export ftp_proxy=$proxy
#http_proxy=$proxy
#ftp_proxy=$proxy