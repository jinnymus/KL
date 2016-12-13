#!/bin/sh
rm -rf /usr/local/csn/etc/$1.bak
cp -rf /usr/local/csn/etc/$1 /usr/local/csn/etc/$1.bak