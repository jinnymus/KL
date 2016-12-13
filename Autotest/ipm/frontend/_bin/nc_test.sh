#!/bin/sh
{
nc -z 172.16.134.59 443
} > out 2> error