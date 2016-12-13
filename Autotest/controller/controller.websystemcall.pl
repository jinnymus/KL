#!/usr/bin/perl	
$service=shift;
$options=shift;
$type=shift;
if ($service eq "hips")
{
	$program="/export/file/monitor/_bin/hips_test";
}
elsif ($service eq "url")
{
	$program="/export/url/monitor/_bin/csn_urlrep";
}
elsif ($service eq "pbs")
{
	$program="/export/clients/pbs/pbs_client";
}
else
{
	#print "select client program service = ".$service."<br>\n";
	#print "select client program options = ".$service."<br>\n";
	#print "select client program type = ".$type."<br>\n";
}
@result=`$program $options`;
foreach(@result)
{
	chomp $_;
	if ($type eq "html")
	{
		print $_."<br>\n";
	}
	elsif ($type eq "text")
	{
		print $_."\n";
	}
}