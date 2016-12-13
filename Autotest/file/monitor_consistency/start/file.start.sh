#!/bin/sh
if [ -f /export/parameters.dat ]; then
        rm -rf /file/*
        cp -rf /export/file/monitor/* /file
fi
cat /file/status.dat | sed 's/file_monitor=Running/file_monitor=Stopped/g' > /file/status_new.dat
mv /file/status_new.dat /file/status.dat
