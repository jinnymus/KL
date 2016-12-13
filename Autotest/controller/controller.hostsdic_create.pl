#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;

$workpath=shift;
$serversdat=shift;
$hostsdat=shift;

unlink("$workpath/hostsdic.dat");
unlink("$workpath/allhostsdic.dat");

open (servers,$serversdat);
open (hostsdic,">> $workpath/hostsdic.dat");
open (hostsdat,$hostsdat);
open (allhostsdic,">> $workpath/allhostsdic.dat");

@hostsdat=<hostsdat>;
foreach $host (@hostsdat) 
{
	chomp $host;
	#$server_name=`/export/controller/controller.hosts_analyzer.sh $hostsdat $server`;
	#$host_info=`host $host`;
	@addresses=();
	@addresses = gethostbyname($host);
	@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
	#$ip=cut($host_info,"3"," ");
	$ip=$addresses[0];
	foreach (@addresses)
	{
		print "host = ".$host." ip _= ".$_."\n";
	}
	chomp $ip;
	print "host = ".$host." ip 1 = ".$ip."\n";
	print allhostsdic $ip."=".$host."\n";
}
close(allhostsdic);


@servers=<servers>;
foreach $server (@servers) 
{
	chomp $server;
	print "server = ".$server."\n";
	#$server_name=`/export/controller/controller.hosts_analyzer.sh $hostsdat $server`;
	$server_name="";
	$server_name=seach_params2("$workpath/allhostsdic.dat",$server);
	chomp $server_name;
	print "server_name = ".$server_name."\n";
	print hostsdic $server."=".$server_name."\n";
}
close(servers);
close(hostsdic);

sub seach_params2
{
	($file,$param) = @_;
	open(parameters, $file) or die "Error open file: $!";
	$parameter="null";
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
	@a=split("$delimeter", $string);
	$value=$a[$number];
return $value;
}