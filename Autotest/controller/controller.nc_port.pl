#!/usr/bin/perl

$server=shift;
$port=shift;
$nc=`nc -z '$server' '$port' 2>&1`;
sub cut
{
	($string,$number,$delimeter) = @_;
	@a=split("$delimeter", $string);
	$value=$a[$number];
return $value;
}
print cut($nc,"6"," ");