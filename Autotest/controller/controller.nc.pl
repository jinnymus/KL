#!/usr/bin/perl

$server=shift;
$nc=`nc -z '$server' 443 2>&1`;
sub cut
{
	($string,$number,$delimeter) = @_;
	@a=split("$delimeter", $string);
	$value=$a[$number];
return $value;
}
print cut($nc,"6"," ");