#!/bin/sh
pwd=`pwd`
echo "pwd = "$pwd
cd /jail/export
git add -A
echo "commit string  = "$1
git commit -m "$1"
echo "git push"
git push
cd $pwd
