#!/usr/bin/perl
$type=shift;
$a=shift;
$b=shift;
if ($type = "devide")
{
	if ($a != 0)
	{
		$c=$a/$b;
	}
	else
	{
		return 0;
	}
}
if ($type = "x")
{
	if ($a != 0)
	{
		$c=$a*$b;
	}
	else
	{
		return 0;
	}
}
print $c."\n";
