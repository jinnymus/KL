#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use Time::Piece;


$tm = localtime;
$year=$tm->year;
$mon=($tm->mon);
$day=$tm->mday;
$hour=$tm->hour;
$min=$tm->min;
$sec=$tm->sec;

if ($mon < 10)
{
	$mon="0".$mon;
}
else
{
	$mon=$mon;
}
if ($day < 10)
{
	$day="0".$day;
}
else
{
	$day=$day;
}
if ($hour < 10)
{
	$hour="0".$hour;
}
else
{
	$day=$day;
}
if ($min < 10)
{
	$min="0".$min;
}
else
{
	$min=$min;
}
if ($sec < 10)
{
	$sec="0".$sec;
}
else
{
	$sec=$sec;
}

$datetime=$year.$mon.$day;

if ($mon == 1)
{
	$mon_need=12;
	$year_need=$year-1;
}
else
{
	$mon=($tm->mon-1);
	if ($mon < 10)
	{
		$mon="0".$mon;
	}
	else
	{
		$mon=$mon;
	}
	$mon_need=$mon;
	print "mon = ".$mon."\n";
	$year_need=$year;
}

$storage_folder="/export/storage/";
$datetime_need=$year_need.$mon_need.$day;
$datetime_need_date = Time::Piece->strptime($datetime_need, "%Y%m%d");

#$datetime_full=($tm->year+1900).'-'.(($tm->mon)+1).'-'.$tm->mday.'_'.$tm->hour.':'.$tm->min.':'.$tm->sec;
#$datetime=($tm->year+1900).(($tm->mon)+1).$tm->mday;

print "datetime now = ".$datetime."\n";
print "datetime need = ".$datetime_need."\n";
print "datetime need date = ".$datetime_need_date."\n";

#@result = get_files("file_monitor_consistency");
#print "result_files count = ".scalar(@result)."\n";

remove_files("file_monitor");
remove_files("file_monitor_sha256");
remove_files("file_monitor_check");
remove_files("file_monitor_consistency");
remove_files("file_monitor_consistency_sha256");
remove_files("file_monitor_diff");
remove_files("file_monitor_diff_sha256");
remove_files("file_monitor_diff_speed");
remove_files("file_monitor_diff_speed_sha256");
remove_files("key_monitor");
remove_files("simple_monitor_check");
remove_files("tc_monitor");
remove_files("url_monitor");
remove_files("url_monitor_kddi");
remove_files("url_monitor_consistency");
remove_files("url_monitor_diff_speed");
remove_files("url_monitor_virustotal");
remove_files("woc_monitor_consistency");

sub get_files
{
	$folder=shift;
	$folder_files=$storage_folder.$folder;
	print "Get files from folder ".$folder_files."\n";	
	opendir(DIR, $folder_files);	
	@FILES_all= readdir(DIR); 
	print "count FILES = ".scalar(@FILES_all)."\n";
	@FILES=grep(/tar/,@FILES_all);
	@result_files=();
	$indx=0;
	foreach $file (@FILES)
	{
		chomp($file);
		$datefile=cut($file,"0",".");
		#print "file = ".$file."\n";		
		#print "datefile = ".$datefile."\n";
		$datefiledate = Time::Piece->strptime($datefile, "%Y%m%d%H%M");
		if ($datefiledate < $datetime_need_date)
		{
			#print "date ".$datefiledate." < ".$datetime_need_date."\n";
			$result_files[$indx]=$file;
			print "file = ".$file."\n";	
			$indx++;
		}
		#print "datefile date = ".$datefiledate."\n";
	}
	return @result_files;
}
sub remove_files
{
	$folder=shift;
	#*mas=shift;	
	@mas = get_files($folder);	
	print "Remove files from folder ".$folder."\n";
	print "result_files count = ".scalar(@mas)."\n";	
	print "=====================================\n";
	$folder_files=$storage_folder.$folder;	
	foreach(@mas)
	{
		chomp $_;
		print "delete file = ".$folder_files."/".$_."\n";
		unlink($folder_files."/".$_);
	}
	print "=====================================\n";
}

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