#!/usr/bin/perl

use v5.10;

$path=shift;
$type=shift;
$log=shift;
chomp $type;
$fe_ip_address=seach_params2($path."/parameters.dat","fe_ip_address");
$status="";
open(logname,">> ".$log);
print logname "type = ".$type."\n";
print logname "fe_ip_address = ".$fe_ip_address."\n";
@res=();
@res_shell=();
@res=`/usr/local/etc/rc.d/csn_frontend $type 2>&1`;
print logname "sleep 60\n";
sleep 60;
for($i=0;$i<100;$i++)
{
	@res_shell=`nc -z $fe_ip_address 443 2>&1`;
	print logname "count res = ".scalar(@res_shell)."\n";
	
	if (scalar(@res_shell) == 0)
	{
		$status="Stopped";
		#print $status."\n";
		#print "Stopped\n";
		print logname "Stopped\n";
		if ($type eq "stop")
		{
			print "Stopped\n";
			exit;
		}
	}
	elsif (grep(/succeeded/,@res_shell))
	{
		$status="Started";
		#print $status."\n";	
		#print "Started\n";
		print logname "Started\n";		
		if ($type eq "start")
		{
			print "Started\n";
			exit;
		}		
	}
	sleep 1;
}

close(logname);
open(file,"> ".$path."/_bin/logfileout_".$type);
print file "res\n";
print file "----\n";
foreach(@res)
{
	print file $_;
}
print file "<br>\n";
print file "----\n";
print file "nc\n";
print file "----\n";
foreach(@res_shell)
{
	print file $_;
}
close(file);

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