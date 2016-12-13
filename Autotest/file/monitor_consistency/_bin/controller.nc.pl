#!/usr/bin/perl

$server=shift;
$log=shift;
print file "[controller.nc.pl] start server = ".$server."\n";
$nc=`nc -z '$server' 443 2>&1`;
chomp $nc;
if ($log ne "")
{
	open(file,">> ".$log);
}
sub cut
{
	(my $string,my $number,my $delimeter) = @_;
	my @a=split("$delimeter", $string);
	my $value=$a[$number];
return $value;
}
my $result = cut($nc,"6"," ");
print $result;
print file "[controller.nc.pl] server = ".$server." nc = ".$nc."\n";
close(file);