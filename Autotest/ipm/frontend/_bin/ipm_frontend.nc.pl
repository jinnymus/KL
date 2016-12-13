#!/usr/bin/perl

use v5.10;

$path=shift;
$log=shift;

$fe_ip_address=seach_params2($path."/parameters.dat","fe_ip_address");
$status="";
open(logname,">> ".$log);
print logname "fe_ip_address = ".$fe_ip_address."\n";
@res_shell=();
@res_shell=`nc -z $fe_ip_address 443 2>&1`;

if (scalar(@res_shell) == 0)
{
	$status="Stopped";
	print "Stopped\n";
	print logname "Stopped nc\n";	
}
elsif (grep(/succeeded/,@res_shell))
{
	$status="Started";
	print "Started\n";
	print logname "Started nc\n";			
}
close(logname);
sub seach_params2
{
	($file,$param) = @_;
	open(parameters, $file) or die "Error open file: $!";
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