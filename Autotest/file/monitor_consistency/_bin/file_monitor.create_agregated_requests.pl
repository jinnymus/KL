#!/usr/bin/perl

use Time::localtime;
use v5.10;
use Switch;
use Socket;
use DBI;
use DBD::Sybase;
use XML::DOM;
use Fcntl;

$path=shift;
$pathlogs=shift;

unlink($pathlogs."/file_file_agregatedreqdebug_.log");
print_time("path = ".$path);
print_time("pathlogs = ".$pathlogs);

print_time("open file_servers");	
open(file_servers,$path."/file_servers.dat");
@file_servers_unsort=<file_servers>;
@file_servers=sort(@file_servers_unsort);
print_time("start foreach file_servers");	
print_time("count file_servers = ".scalar(@file_servers));	
print_time("count file_servers_unsort = ".scalar(@file_servers_unsort));	

my @md5s;

foreach my $file_server (@file_servers)
{
	chomp $file_server;
	#$file_server=$_;
	print_time("file_server = ".$file_server);
	
	if ($file_server ne "")
	{
		$file_server_name=seach_params2($path."/hostsdic.dat",$file_server);
		print_time("file_server_name = ".$file_server_name);
			
		open (logfile_fail,$pathlogs."/file_fail_".$file_server.".log");
		@logfile_fail=<logfile_fail>;
		@rows_fail=grep(/md5 = /,@logfile_fail);	
		$count_fail=scalar(@rows_fail);	
		if($count_fail eq "")
		{
			$count_fail=0;
		}
		print_time("count_fail = ".$count_fail);		
		
		open (logfile_mustnotbutexist,$pathlogs."/file_mustnotbutexist_".$file_server.".log");
		@logfile_mustnotbutexist=<logfile_mustnotbutexist>;
		@rows_mustnotbutexist=grep(/md5_mas = /,@logfile_mustnotbutexist);		
		$count_mustnotbutexist=scalar(@rows_mustnotbutexist);	
		if($count_mustnotbutexist eq "")
		{
			$count_mustnotbutexist=0;
		}
		print_time("count_mustnotbutexist = ".$count_mustnotbutexist);			
		
		foreach my $line (@rows_fail)
		{
			chomp $line;
			my $md5 = cut($line,"2"," ");
			if (grep(/$md5/,@md5s))
			{
				print_time("md5s massive fail md5 exist = ".$md5);									
			}
			else
			{
				print_time("md5s massive fail md5 push = ".$md5);												
				push (@md5s,$md5);		
			}			
		}
		
		foreach my $line (@rows_mustnotbutexist)
		{
			chomp $line;
			my $md5 = cut($line,"2"," ");
			if (grep(/$md5/,@md5s))
			{
				print_time("md5s massive mustnotbutexist md5 exist = ".$md5);									
			}
			else
			{
				print_time("md5s massive mustnotbutexist md5 push = ".$md5);												
				push (@md5s,$md5);		
			}			
		}
	}
}

print_time("md5s count = ".scalar(@md5s));					

unlink ($pathlogs."/request_md5s_1_.dat");
open (request,">> ".$pathlogs."/request_md5s_1_.dat");
foreach my $md5 (@md5s)
{
	print_time("md5s = ".$md5);
	print request $md5."\n";
}
close(request);

sub print_time
{
	#my $file_=shift;
	my $text=shift;
	#$path_print_time="/export/file/monitor_consistency/_bin";
	
	open (debug_file,">> ".$pathlogs."/file_agregatedreqdebug_.log");	
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print debug_file "[DEBUG] [".$datetime_now."] [".$text."]\n";
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
	close(debug_file);
}
sub seach_params2
{
	($file,$param) = @_;
	open(parameters, $file) or die "Error open file: $!";
	$param_name="";
	while(<parameters>) {
		$param_name=cut($_,"0","=");
		if ($param_name eq $param)
		{
			$parameter=cut($_,"1","=");
		}
	};
	close(parameters);
	chomp $parameter;
return $parameter;
}
sub cut
{
	($string,$number,$delimeter) = @_;
	if ($delimeter eq ".")
	{
		@a=split("\\.", $string);
	}
	else
	{
		@a=split("$delimeter", $string);
	}
	$value=$a[$number];
return $value;
}