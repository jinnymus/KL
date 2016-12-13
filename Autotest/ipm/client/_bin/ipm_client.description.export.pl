#!/usr/bin/perl
sub seach_params
{
	($file,$param,$start) = @_;
	$i = 1;
	#print $param;
	open(parameters, $file) or die "Error open file: $!";
	@parameters=<parameters>;
	$parameter="";
	foreach (@parameters) 
	{
		if ($start == 1) 
		{
			$where = index($_,$param);
			if ($where == -1) 
			{
			}
			else 
			{
				$where = index($_,"=");
				$wheren = index($_,"\n");
				$len=$wheren-$where-1;
				$parameter=substr($_,$where+1,$len); 
			}
		}
		else 
		{	
			#print "i = ".$i."\n";
			if ($i >= $start) 
			{
				
				$parameter=$parameter.$_;
			}
		}
		$i = $i + 1;	
	};
	close(parameters);
return $parameter;
}
open(testplan,"../testplan.dat");
system("rm ../test_desc.csv");
open(test_desc,"> ../test_desc.csv");
print test_desc "tfsid;title;priority;automation_status;state;area;iteration;tested_user_stories;all_links;description;work_item;\n";
@testplan=<testplan>;
foreach (@testplan) 
{
#print $_;
#$cd='cd '.$_;
#print $cd;
#exec ($cd);
#system("pwd");
chomp $_;
print "Exporting test ".$_."\n";
#print $_."/desc";
$tfsid=seach_params('../'.$_.'/desc','TFSID',1);
$title=seach_params('../'.$_.'/desc','title',1);
$priority=seach_params('../'.$_.'/desc','Priority',1);
$automation_status=seach_params('../'.$_.'/desc','Automation_Status',1);
$State_status=seach_params('../'.$_.'/desc','State_status',1);
$area=seach_params('../'.$_.'/desc','Area',1);
$iteration=seach_params('../'.$_.'/desc','Iteration',1);
$tested_user_stories=seach_params('../'.$_.'/desc','Tested_User_Stories',1);
$all_links=seach_params('../'.$_.'/desc','All_links',1);
$description=seach_params('../'.$_.'/desc','All_links',10);
#$description="description\nerg\n";
#print "title = ".$title."\n";
#print "priority = ".$priority."\n";
#print "automation_status = ".$automation_status."\n";
#print "state = ".$state."\n";
#print "area = ".$area."\n";
#print "iteration = ".$iteration."\n";
#print "tested_user_stories = ".$tested_user_stories."\n";
#print "all_links = ".$all_links."\n";
#print "description = ".$description."\n";
print test_desc $tfsid.";".$title.";".$priority.";".$automation_status.";".$State_status.";".$area.";".$iteration.";".$tested_user_stories.";".$all_links.";\"".$description."\";Test Case;\n";
}
close(testplan);
close(test_desc);
