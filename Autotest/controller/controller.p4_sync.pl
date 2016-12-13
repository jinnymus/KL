#!/usr/bin/perl
$ENV{'SHELL'}="/bin/sh";
$ENV{'P4PORT'}="pf.avp.ru:1666";
$ENV{'P4CLIENT'}="controller_autotester_geoconf";
$ENV{'P4HOST'}="controller_autotester";
$ENV{'P4USER'}="Kalistratov";
$ENV{'P4PASSWD'}="******";
$ENV{'P4ROOT'}="/export/perforce/controller_autotester_geoconf";

@p4infores=`p4 sync`;

print "P4 sync result:\n";
print "------------\n";
foreach $line (@p4infores)
{
	chomp($line);
	print $line."\n";
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