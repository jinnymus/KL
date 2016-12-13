#!/usr/bin/perl

use Time::localtime;
use v5.10;
#use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;

$shell=shift;

$SIG{ALRM} = sub { 
				#close(FOR_READ_TIME);	
				#close(FOR_WRITE_TIME);	
				#print "run_prog ".$shell." was killed by timeout. parent ".$ppid."\n"; 
				die "timeout shell = ".$shell; 
				}; 
eval 
{ 
	alarm(50); 
};	

@resp=`$shell`;

foreach (@resp)
{
	print $_;
}
