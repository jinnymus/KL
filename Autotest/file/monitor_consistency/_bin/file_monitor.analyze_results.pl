#!/usr/bin/perl

use Time::localtime;
#use strict;
use v5.10;
#use Time::HiRes;
#use threads;
use v5.10;
use Switch;
use Socket;
use DBI;
use DBD::Sybase;
use XML::DOM;
use Fcntl;
use DateTime::Format::Strptime qw();
use MIME::Base64 qw(encode_base64 decode_base64);

$format_sql = DateTime::Format::Strptime->new(
											pattern   => '%Y-%m-%d %H:%M:%S',
										);	
#$path=seach_params2('/file/parameters.dat','path');
#$packet_size=seach_params2('/file/parameters.dat','packet_file_size');
$analyze_limit=seach_params2('/file/parameters.dat','analyze_limit');

$path=shift;
$pathlogs=shift;
$md5_type=shift;

unlink($pathlogs."/file_analyzdebug_.log");
print_time("path = ".$path);
print_time("pathlogs = ".$pathlogs);
print_time("md5_type = ".$md5_type);
$prefix_fail="1";
$prefix_exist="2";
if ($md5_type eq "all")
{
	$prefix_fail_ok="10";
	$prefix_exist_ok="20";
}

opendir(resultlogsdir, $pathlogs);
@resultlogsall= readdir(resultlogsdir); 
@resultlogs=grep(/analyze/,@resultlogsall);
print_time("delete resultlogs");
foreach my $log (@resultlogs)
{
	chomp ($log);
	print_time("delete resultlogs ".$log);
	unlink($pathlogs."/".$log);
}
#opendir(DIR, "/export/test");
#@FILES= readdir(DIR); 
#$count_files=scalar(@logs_mustnot);
#print "count count_files = ".$count_files."\n";

@mas=();
$indx_mas=0;

#$dbh_fe = frontend_db_connect();
#$dbh_audit = audit_search_connect();
	
print_time("open file_servers");	
open(file_servers,$path."/file_servers.dat");
@file_servers_unsort=<file_servers>;
@file_servers=sort(@file_servers_unsort);
print_time("start foreach file_servers");	
print_time("count file_servers = ".scalar(@file_servers));	
print_time("count file_servers_unsort = ".scalar(@file_servers_unsort));	
foreach my $file_server (@file_servers)
{
	chomp $file_server;
	#$file_server=$_;
	print_time("file_server = ".$file_server);
	
	if ($file_server ne "")
	{
		$file_server_name=seach_params2($path."/hostsdic.dat",$file_server);
		print_time("file_server_name = ".$file_server_name);
			
		open (logfile_fail,$pathlogs."/file_fail_".$file_server.".log");
		@logfile_fail=<logfile_fail>;
		@rows_fail=grep(/md5 = /,@logfile_fail);	
		$count_fail=scalar(@rows_fail);	
		if($count_fail eq "")
		{
			$count_fail=0;
		}
		print_time("count_fail = ".$count_fail);		
		
		open (logfile_mustnotbutexist,$pathlogs."/file_mustnotbutexist_".$file_server.".log");
		@logfile_mustnotbutexist=<logfile_mustnotbutexist>;
		@rows_mustnotbutexist=grep(/md5_mas = /,@logfile_mustnotbutexist);		
		$count_mustnotbutexist=scalar(@rows_mustnotbutexist);	
		if($count_mustnotbutexist eq "")
		{
			$count_mustnotbutexist=0;
		}
		print_time("count_mustnotbutexist = ".$count_mustnotbutexist);			
		
		if ($md5_type eq "all")
		{
			open (logfile_ok,$pathlogs."/file_ok_".$file_server.".log");
			@logfile_ok=<logfile_ok>;
			@rows_ok=grep(/md5_mas = /,@logfile_ok);	
			$count_ok=scalar(@rows_ok);	
			if($count_ok eq "")
			{
				$count_ok=0;
			}
			print_time("count_ok = ".$count_ok);		
			
			open (logfile_mustnot,$pathlogs."/file_mustnot_".$file_server.".log");
			@logfile_mustnot=<logfile_mustnot>;
			@rows_mustnot=grep(/md5_mas = /,@logfile_mustnot);		
			$count_mustnot=scalar(@rows_mustnot);	
			if($count_mustnot eq "")
			{
				$count_mustnot=0;
			}
			print_time("count_mustnot = ".$count_mustnot);			
		
			@{"ok_md5_".$file_server}=get_cut_from_mas("2"," ",*rows_ok);
			@{"mustnot_md5_".$file_server}=get_cut_from_mas("2"," ",*rows_mustnot);
			
			foreach(@{"ok_md5_".$file_server})
			{
				print_time("ok_md5_ = ".$_);						
			}
			
			foreach(@{"mustnot_md5_".$file_server})
			{
				print_time("mustnot_md5_ = ".$_);									
			}
			
		}
		
		@{"fail_md5_".$file_server}=get_cut_from_mas("2"," ",*rows_fail);
		@{"mustnotbutexist_md5_".$file_server}=get_cut_from_mas("2"," ",*rows_mustnotbutexist);
		
		foreach(@{"fail_md5_".$file_server})
		{
			print_time("fail_md5_ = ".$_);						
		}
		
		foreach(@{"mustnotbutexist_md5_".$file_server})
		{
			print_time("mustnotbutexist_md5_ = ".$_);									
		}
	}
}

print_time("analyze results");	

my @result_fail_md5s=();
my @result_mustnotbutexist_md5s=();
if ($md5_type eq "all")
{
	my @result_ok_md5s=();
	my @result_mustnot_md5s=();
}
foreach my $file_server (@file_servers)
{
	foreach my $md5 (@{"fail_md5_".$file_server})
	{
		if (grep(/$md5/,@result_fail_md5s))
		{
			print_time("analyze massives fail_md5_ md5 exist = ".$md5);					
		}
		else
		{
			print_time("analyze massives md5 push = ".$md5);						
			push (@result_fail_md5s,$md5);		
		}
	}
	foreach my $md5 (@{"mustnotbutexist_md5_".$file_server})
	{
		if (grep(/$md5/,@result_mustnotbutexist_md5s))
		{
			print_time("analyze massives mustnotbutexist_md5_ md5 exist = ".$md5);									
		}
		else
		{
			print_time("analyze massives mustnotbutexist_md5_ md5 push = ".$md5);												
			push (@result_mustnotbutexist_md5s,$md5);		
		}
	}
	if ($md5_type eq "all")
	{
		foreach my $md5 (@{"ok_md5_".$file_server})
		{
			if (grep(/$md5/,@result_ok_md5s))
			{
				print_time("analyze massives ok_md5_ md5 exist = ".$md5);					
			}
			else
			{
				print_time("analyze massives md5 push = ".$md5);						
				push (@result_ok_md5s,$md5);		
			}
		}
		foreach my $md5 (@{"mustnot_md5_".$file_server})
		{
			if (grep(/$md5/,@result_mustnot_md5s))
			{
				print_time("analyze massives mustnot_md5_ md5 exist = ".$md5);									
			}
			else
			{
				print_time("analyze massives mustnot_md5_ md5 push = ".$md5);												
				push (@result_mustnot_md5s,$md5);		
			}
		}
	}	
}

@pids;
my $i_pids=0;

print_time("call wl_connect");	
my $dbh_wl = wl_connect();
my $dbh_audit = audit_search_connect();
		
print_time("foreach result_fail_md5s");	
foreach my $md5 (@result_fail_md5s)
{
	@{$md5."_".$prefix_fail};
	print_time("analyze name mas = ".$md5."_".$prefix_fail);
	print_time("analyze massives result_fail_md5s = ".$md5);				
	print_time("analyze massives call audit_search");					
	#my $pid=fork();
	#if ($pid==0)
	#{
		#my $dbh_audit = audit_search_connect();
		audit_search($dbh_audit,$dbh_fe,$md5,$prefix_fail,$dbh_wl);
		#$dbh_audit->disconnect;
	#	exit;
	#}	
	#else
	#{
	#	print "Starting fork at pid=".$pid." md5 = ".$md5."\n";
	#	$pids[$i_pids]=$pid.";".$md5.";".$prefix_fail;
	#	$i_pids++;
	#}	
}

print_time("foreach result_mustnotbutexist_md5s");	
foreach $md5 (@result_mustnotbutexist_md5s)
{
	@{$md5."_".$prefix_exist};
	print_time("analyze name mas = ".$md5."_".$prefix_exist);	
	print_time("analyze massives result_mustnotbutexist_md5s = ".$md5);				
	print_time("analyze massives call audit_search");					
	#my $pid=fork();
	#if ($pid==0)
	#{
		#my $dbh_audit = audit_search_connect();
		audit_search($dbh_audit,$dbh_fe,$md5,$prefix_exist,$dbh_wl);	
		#$dbh_audit->disconnect;
	#	exit;
	#}	
	#else
	#{
	#	print "Starting fork at pid=".$pid." md5 = ".$md5."\n";
	#	$pids[$i_pids]=$pid.";".$md5.";".$prefix_exist;
	#	$i_pids++;
	#}	
}

if ($md5_type eq "all")
{
	print_time("foreach result_ok_md5s");	
	foreach my $md5 (@result_ok_md5s)
	{
		@{$md5."_".$prefix_fail_ok};
		print_time("analyze name mas = ".$md5."_".$prefix_fail_ok);
		print_time("analyze massives result_ok_md5s = ".$md5);				
		print_time("analyze massives call audit_search");					
		#my $pid=fork();
		#if ($pid==0)
		#{
			#my $dbh_audit = audit_search_connect();
			audit_search($dbh_audit,$dbh_fe,$md5,$prefix_fail_ok,$dbh_wl);
			#$dbh_audit->disconnect;
		#	exit;
		#}	
		#else
		#{
		#	print "Starting fork at pid=".$pid." md5 = ".$md5."\n";
		#	$pids[$i_pids]=$pid.";".$md5.";".$prefix_fail_ok;
		#	$i_pids++;
		#}	
	}

	print_time("foreach result_mustnot_md5s");	
	foreach $md5 (@result_mustnot_md5s)
	{
		@{$md5."_".$prefix_exist_ok};
		print_time("analyze name mas = ".$md5."_".$prefix_exist_ok);	
		print_time("analyze massives result_mustnot_md5s = ".$md5);				
		print_time("analyze massives call audit_search");					
		#my $pid=fork();
		#if ($pid==0)
		#{
			#my $dbh_audit = audit_search_connect();
			audit_search($dbh_audit,$dbh_fe,$md5,$prefix_exist_ok,$$dbh_wl);	
			#$dbh_audit->disconnect;
		#	exit;
		#}	
		#else
		#{
		#	print "Starting fork at pid=".$pid." md5 = ".$md5."\n";
		#	$pids[$i_pids]=$pid.";".$md5.";".$prefix_exist_ok;
		#	$i_pids++;
		#}	
	}
}
#foreach my $line (@pids)
#{
#	
#	waitpid (cut($line,"0",";"),0);
#}

#print_time("foreach result_fail_md5s");	
#foreach $md5 (@result_fail_md5s)
#{
#	print_time("analyze massives result_fail_md5s = ".$md5);				
#	print_time("analyze massives call audit_search");					
#	audit_search($dbh_audit,$dbh_fe,$md5,$prefix_fail);
#}
#
#print_time("foreach result_mustnotbutexist_md5s");	
#foreach $md5 (@result_mustnotbutexist_md5s)
#{
#	print_time("analyze massives result_mustnotbutexist_md5s = ".$md5);				
#	print_time("analyze massives call audit_search");					
#	audit_search($dbh_audit,$dbh_fe,$md5,$prefix_exist);	
#}

print_time("disconnect dbs");	
$dbh_wl->disconnect;
$dbh_audit->disconnect;
#$dbh_audit->disconnect;
#$dbh_fe->disconnect;

print_time("create notfound analyze file");	
open (file_analyzed_dic,">> ".$pathlogs."/file_analyzeddic_.log");	
@file_analyzed_dic=<file_analyzed_dic>;
print_time("count file_analyzed_dic = ".scalar(@file_analyzed_dic));	
print_time("count result_fail_md5s = ".scalar(@result_fail_md5s));	
print_time("count result_mustnotbutexist_md5s = ".scalar(@result_mustnotbutexist_md5s));	
foreach my $md5 (@result_fail_md5s)
{
	if (grep/$md5/,@file_analyzed_dic)
	{
		print_time("md5 = ".$md5." type fail_notfound");		
		print_file("fail_notfound", $md5);
	}
	# print_fulldic("===========================================");
	# print_fulldic("MD5 ".$md5." mustnotexist");
	# foreach my $file_server (@file_servers)
	# {
		# if (grep/$md5/,@{"fail_md5_".$file_server})
		# {
			# print_fulldic($file_server);
		# }
	# }
}
foreach my $md5 (@result_mustnotbutexist_md5s)
{
	if (grep/$md5/,@file_analyzed_dic)
	{
		print_time("md5 = ".$md5." type exist_notfound");		
		print_file("exist_notfound", $md5);
	}	
	# print_fulldic("===========================================");
	# print_fulldic("MD5 ".$md5." mustnotbutexist");	
	# foreach my $file_server (@file_servers)
	# {
		# if (grep/$md5/,@{"mustnotbutexist_md5_".$file_server})
		# {
			# print_fulldic($server);
		# }
	# }
}

if ($md5_type eq "all")
{
	print_time("count result_ok_md5s = ".scalar(@result_ok_md5s));	
	print_time("count result_mustnot_md5s = ".scalar(@result_mustnot_md5s));	
	foreach my $md5 (@result_ok_md5s)
	{
		if (grep/$md5/,@file_analyzed_dic)
		{
			print_time("md5 = ".$md5." type fail_ok_notfound");		
			print_file("fail_ok_notfound", $md5);
		}
		# print_fulldic("===========================================");
		# print_fulldic("MD5 ".$md5." ok");
		# foreach my $file_server (@file_servers)
		# {
			# if (grep/$md5/,@{"ok_md5_".$file_server})
			# {
				# print_fulldic($file_server);
			# }
		# }
	}
	foreach my $md5 (@result_mustnot_md5s)
	{
		if (grep/$md5/,@file_analyzed_dic)
		{
			print_time("md5 = ".$md5." type exist_ok_notfound");		
			print_file("exist_ok_notfound", $md5);
		}	
		# print_fulldic("===========================================");
		# print_fulldic("MD5 ".$md5." mustnot");	
		# foreach my $file_server (@file_servers)
		# {
			# if (grep/$md5/,@{"mustnot_md5_".$file_server})
			# {
				# print_fulldic($server);
			# }
		# }
	}
}

close(file_servers);
close(file_analyzed_dic);
print_time("end script");	

sub wl_connect
{
	print_time("wl_connect main start");					
	my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;	
	my $DBI;
	print_time("wl_connect main DBI connect");						
	$dbh = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
		{
			PrintError  => 0,
			HandleError => \&handle_error_wl,
		}
		) or handle_error_wl($DBI->errstr);
	print_time("wl_connect main syb_date_fmt");							
	$dbh->syb_date_fmt('ISO');		
	print_time("wl_connect main return dbh");								
	return $dbh;
}
sub audit_search_connect
{
	print_time("audit_search_connect main start");					
	my ($host,$port,$instance,$database,$user,$pass) = ("MSSQL","1433","SQLEXPRESS","PUB","KL\\kalistratov","Y6UHYziF");
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;	
	my $DBI;
	print_time("audit_search_connect main DBI connect");						
	$dbh = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
		{
			PrintError  => 0,
			HandleError => \&handle_error,
		}
		) or handle_error($DBI->errstr);
	print_time("audit_search_connect main syb_date_fmt");							
	$dbh->syb_date_fmt('ISO');		
	print_time("audit_search_connect main return dbh");								
	return $dbh;
}
sub audit_search
{
	my $dbh_audit=shift;
	my $dbh_fe=shift;	
	my $md5_audit=shift;
	my $prefix=shift;	
	my $dbh_wl=shift;
	
	$sql="";
	$status=0;
	$status_change=0;
	$status_publish=0;
	$status_delete=0;
	$aush_workload_guid="NULL";
	print_time("audit_search main start");		
	print_time("audit_search md5 = ".$md5_audit);			
	$sql="select * from audit.search where aush_md5 = (0x".$md5_audit.") and aush_data_flow_id = 5 order by 1 desc";
	print_time("audit_search sql = ".$sql);				

	$sth_full = $dbh_audit->prepare($sql);
	$sth_full -> execute();
	
	my $rows_full_indx=0;
		
	while(@rows = $sth_full->fetchrow_array()) 
	{
		print_time("audit_search ============================================= full md5_audit = ".$md5_audit);		
		$aush_create_date=$rows[0];
		$aush_workload_guid=$rows[1];		
		$aush_dataflow_id=$rows[2];		
		$aush_message=$rows[3];		
		$aush_dtflw_msg_type_id=$rows[5];		
		${$md5_audit."_audit"}[$rows_full_indx]=$aush_workload_guid." ".$aush_create_date." ".$aush_dataflow_id." ".$aush_message." ".$aush_dtflw_msg_type_id;	
		@xml_result_audit = audit_xml($aush_message);
		my $message_guid=$xml_result_audit[0];
		print_time("audit_search rows_audit_full message_guid = ".$message_guid);			
		${$message_guid."_tasklog_ref"} = \@{$message_guid."_tasklog"};
		TaskLog_full($dbh_audit,$dbh_fe,$message_guid,$md5_audit,$prefix,${$message_guid."_tasklog_ref"});			
		print_time("audit_search tasklog start ".$message_guid."_tasklog count = ".scalar(@{$message_guid."_tasklog"}));		
		$rows_full_indx++;
	}
	$sth_full -> finish;
	
	print_time("audit_search ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));
	
	$sth = $dbh_audit->prepare($sql);
	$sth -> execute();

	my @rows;
	#my @{$md5_audit."_audit"};
	my $rows_full_indx=0;
	my $wl_result = get_wl($md5_audit,$dbh_wl);
	
	my $prefix_compare=0;
	if ($prefix == 10 || $prefix == 1)
	{
		$prefix_compare=1;
	}
	elsif ($prefix == 20 || $prefix == 2)
	{
		$prefix_compare=2;
	}
	print_time("audit_search prefix = ".$prefix);
	print_time("audit_search prefix_compare = ".$prefix_compare);
	
	while(@rows = $sth->fetchrow_array()) 
	{ 
		print_time("audit_search ============================================= md5_audit = ".$md5_audit);	
		my @xml_result_audit=();	
		
		$aush_create_date=$rows[0];
		$aush_workload_guid=$rows[1];		
		$aush_dataflow_id=$rows[2];		
		$aush_message=$rows[3];		
		$aush_dtflw_msg_type_id=$rows[5];		

		print_time("audit_search rows_audit xml = ".$aush_message);				
	
		@xml_result_audit = audit_xml($aush_message);
		my $message_guid=$xml_result_audit[0];
		print_time("audit_search rows_audit message_guid = ".$message_guid);		
		print_time("audit_search rows_audit xml_result_audit 0 = ".$xml_result_audit[0]);						
		print_time("audit_search rows_audit xml_result_audit 1 = ".$xml_result_audit[1]);			
		if (($xml_result_audit[1] == "1") && ($status_delete == 1) && ($status_publish == 0))
		{
			$status_change=1;
		}
		if (($xml_result_audit[1] == "2") && ($status_publish == 1) && ($status_delete == 0))
		{
			$status_change=1;
		}		
		if (($xml_result_audit[1] == $prefix_compare) && ($status_change == 0) && ($status_publish == 0) && ($status_delete == 0))
		{
			$status=1;
			print_time("audit_search rows_audit prefix = ".$prefix);	
			print_time("audit_search rows_audit prefix_compare = ".$prefix_compare);	
			
			my $verdict_audit = $xml_result_audit[3];
			my $verdict_wl = cut($wl_result,"6"," ");
			print_time("audit_search rows_audit verdict_audit = ".$verdict_audit);	
			print_time("audit_search rows_audit verdict_wl = ".$verdict_wl);	
			
			if ($verdict_audit eq $verdict_wl)
			{
				print_time("audit_search call TaskLog");
				TaskLog($dbh_audit,$dbh_fe,$message_guid,$md5_audit,$prefix,${$message_guid."_tasklog_ref"},$aush_create_date);			
			}
			else
			{
				print_file($prefix."_9", $md5_audit, $aush_workload_guid);
				print_time("############################## Case 9 start ##############################");			
				print_time("audit_search rows_audit verdict_audit = ".$verdict_audit);	
				print_time("audit_search rows_audit verdict_wl = ".$verdict_wl);	
				print_time("audit_search rows_audit md5_audit = ".$md5_audit);			
				print_time("############################## Case 9 end ##############################");			
				open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_9_.log");	
				print_time("audit_search tasklog ".$aush_workload_guid."_tasklog count = ".scalar(@{$aush_workload_guid."_tasklog"}));			
				print_time("audit_search audit ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));					
				flock($filefull,LOCK_EX);
				print_full($prefix."_9","======================================================================",$filefull);
				print_full($prefix."_9","		MD5: ".$md5_audit,$filefull);
				foreach my $file_server (@file_servers)
				{
					if (grep/$md5_audit/,@{"fail_md5_".$file_server})
					{
						print_full($prefix."_9","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
					{
						print_full($prefix."_9","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
					{
						print_full($prefix."_9","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
					{
						print_full($prefix."_9","		Server = ".$file_server,$filefull);
					}			
				}
				print_full($prefix."_9","		TIME: ".get_time(),$filefull);
				print_full($prefix."_9","		WL = ".$wl_result,$filefull);
				#print_full($prefix."_9","----------------------------------------------------------------------");
				my $indx_audit=0;
				print_full($prefix."_9","			Audit: ".$aush_workload_guid,$filefull);
				foreach my $line (@{$md5_audit."_audit"})
				{
					my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
					print_full($prefix."_9","			Audit = ".$line,$filefull);
					my $indx_tasklog=0;
					#print_full($prefix."_9","----------------------------------------------------------------------");
					print_full($prefix."_9","		       Tasklog: ".$aush_workload_guid,$filefull);
					foreach (@{$aush_workload_guid."_tasklog"})
					{
						my $line=${$aush_workload_guid."_tasklog"}[$indx_tasklog];
						print_full($prefix."_9","		       Tasklog = ".$line,$filefull);
						$indx_tasklog++;
					}
					$indx_audit++;
				}
				close($filefull);
			}
		}
		if ($xml_result_audit[1] == "1")
		{
			$status_publish=1;
		}
		if ($xml_result_audit[1] == "2")
		{
			$status_delete=1;
		}

		$rows_full_indx++;
	}	
	$rows_audits = $sth->rows;
	print_time("audit_search rows_audit rows_audit = ".$rows_audits);		
	print_time("audit_search md5_audit_mas count = ".scalar(@{$md5_audit."_audit"}));		
	print_time("audit_search audit ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));
	print_time("audit_search tasklog ".$aush_workload_guid."_tasklog count = ".scalar(@{$aush_workload_guid."_tasklog"}));		
	
	if ($rows_audits == 0)
	{
		print_file($prefix."_1", $md5_audit, "none");
		print_time("############################## Case 1 start ##############################");			
		print_time("audit_search rows_audit rows_audits = 0");	
		print_time("audit_search rows_audit md5_audit = ".$md5_audit);			
		print_time("############################## Case 1 end ##############################");			
		open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_1_.log");	
		print_time("audit_search tasklog ".$aush_workload_guid."_tasklog count = ".scalar(@{$aush_workload_guid."_tasklog"}));			
		print_time("audit_search audit ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));					
		flock($filefull,LOCK_EX);
		print_full($prefix."_1","======================================================================",$filefull);
		print_full($prefix."_1","		MD5: ".$md5_audit,$filefull);
		foreach my $file_server (@file_servers)
		{
			if (grep/$md5_audit/,@{"fail_md5_".$file_server})
			{
				print_full($prefix."_1","		Server = ".$file_server,$filefull);
			}
			elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
			{
				print_full($prefix."_1","		Server = ".$file_server,$filefull);
			}
			elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
			{
				print_full($prefix."_1","		Server = ".$file_server,$filefull);
			}
			elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
			{
				print_full($prefix."_1","		Server = ".$file_server,$filefull);
			}			
		}
		print_full($prefix."_1","		TIME: ".get_time(),$filefull);
		print_full($prefix."_1","		WL = ".$wl_result,$filefull);
		#print_full($prefix."_1","----------------------------------------------------------------------");
		my $indx_audit=0;
		print_full($prefix."_1","			Audit: ".$aush_workload_guid,$filefull);
		foreach my $line (@{$md5_audit."_audit"})
		{
			my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
			print_full($prefix."_1","			Audit = ".$line,$filefull);
			my $indx_tasklog=0;
			#print_full($prefix."_1","----------------------------------------------------------------------");
			print_full($prefix."_1","		       Tasklog: ".$aush_workload_guid,$filefull);
			foreach (@{$aush_workload_guid."_tasklog"})
			{
				my $line=${$aush_workload_guid."_tasklog"}[$indx_tasklog];
				print_full($prefix."_1","		       Tasklog = ".$line,$filefull);
				$indx_tasklog++;
			}
			$indx_audit++;
		}
		close($filefull);
	}
	else
	{
		if (($status == 0) && ($status_change == 0))
		{
			print_file($prefix."_2", $md5_audit, "none");
			print_time("############################## Case 2 start ##############################");			
			print_time("audit_search rows_audit status = 0");	
			print_time("audit_search rows_audit md5_audit = ".$md5_audit);						
			print_time("############################## Case 2 end ##############################");		
			open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_2_.log");	
			print_time("audit_search tasklog ".$aush_workload_guid."_tasklog count = ".scalar(@{$aush_workload_guid."_tasklog"}));			
			print_time("audit_search audit ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));						
			flock($filefull,LOCK_EX);
			print_full($prefix."_2","======================================================================",$filefull);
			print_full($prefix."_2","		MD5: ".$md5_audit,$filefull);
			foreach my $file_server (@file_servers)
			{
				if (grep/$md5_audit/,@{"fail_md5_".$file_server})
				{
					print_full($prefix."_2","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
				{
					print_full($prefix."_2","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
				{
					print_full($prefix."_2","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
				{
					print_full($prefix."_2","		Server = ".$file_server,$filefull);
				}			
			}			
			print_full($prefix."_2","		TIME: ".get_time(),$filefull);
			print_full($prefix."_2","		WL = ".$wl_result,$filefull);
			#print_full($prefix."_2","----------------------------------------------------------------------");
			my $indx_audit=0;
			print_full($prefix."_2","			Audit: ".$aush_workload_guid,$filefull);
			foreach my $line (@{$md5_audit."_audit"})
			{
				my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
				print_full($prefix."_2","			Audit = ".$line,$filefull);
				my $indx_tasklog=0;
				#print_full($prefix."_2","----------------------------------------------------------------------");
				print_full($prefix."_2","		       Tasklog: ".$aush_workload_guid,$filefull);
				foreach (@{$aush_workload_guid."_tasklog"})
				{
					my $line=${$aush_workload_guid."_tasklog"}[$indx_tasklog];
					print_full($prefix."_2","		       Tasklog = ".$line,$filefull);
					$indx_tasklog++;
				}
				$indx_audit++;
			}	
			close($filefull);
		}
		if (($status_change == 1) && ($status == 0))
		{
			print_file($prefix."_7", $md5_audit, "none");
			print_time("############################## Case 7 start ##############################");			
			print_time("audit_search rows_audit status_change = 1");	
			print_time("audit_search rows_audit md5_audit = ".$md5_audit);						
			print_time("############################## Case 7 end ##############################");			
			open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_7_.log");	
			print_time("audit_search tasklog ".$aush_workload_guid."_tasklog count = ".scalar(@{$aush_workload_guid."_tasklog"}));			
			print_time("audit_search audit ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));			
			flock($filefull,LOCK_EX);			
			print_full($prefix."_7","======================================================================",$filefull);
			print_full($prefix."_7","		MD5: ".$md5_audit,$filefull);
			foreach my $file_server (@file_servers)
			{
				if (grep/$md5_audit/,@{"fail_md5_".$file_server})
				{
					print_full($prefix."_7","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
				{
					print_full($prefix."_7","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
				{
					print_full($prefix."_7","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
				{
					print_full($prefix."_7","		Server = ".$file_server,$filefull);
				}			
			}			
			print_full($prefix."_7","		TIME: ".get_time(),$filefull);			
			print_full($prefix."_7","		WL = ".$wl_result,$filefull);
			#print_full($prefix."_7","----------------------------------------------------------------------");
			my $indx_audit=0;
			print_full($prefix."_7","			Audit: ".$aush_workload_guid,$filefull);
			foreach my $line (@{$md5_audit."_audit"})
			{
				my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
				print_full($prefix."_7","			Audit = ".$line,$filefull);
				my $indx_tasklog=0;
				#print_full($prefix."_7","----------------------------------------------------------------------");
				print_full($prefix."_7","		       Tasklog: ".$aush_workload_guid,$filefull);
				foreach (@{$aush_workload_guid."_tasklog"})
				{
					my $line=${$aush_workload_guid."_tasklog"}[$indx_tasklog];
					print_full($prefix."_7","		       Tasklog = ".$line,$filefull);
					$indx_tasklog++;
				}
				$indx_audit++;
			}		
			close($filefull);
		}	
	}
}
sub get_time
{
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	return $datetime_now;
}
sub get_wl
{
	my $md5=shift;
	my $dbh_wl=shift;
	print_time("get_wl md5 = ".$md5);
	
	my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;
	
	#$dbh_wl = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
	#	{
	#		PrintError  => 0,
	#		HandleError => \&handle_error,
	#	}
	#	) or handle_error($DBI->errstr);
	#$dbh_wl->syb_date_fmt('ISO');		

	BEGIN 
	{ 
		$ENV{SYBASE} = "/usr/local"; 
	}
	
	@mas_result_sql=();
	my $table_name="#table".$$;
	my $sql="declare \@md5table as MD5Table insert \@md5table( md5 ) values( 0x".cut($md5,"0",";")." );
			CREATE TABLE $table_name (md5 binary(16), sha3 binary(20), TimeAdded datetime, LastZonechangeTime datetime, verdict nvarchar(32),isuploaded nvarchar(32),vendor nvarchar(300),product nvarchar(300),category binary(16));
			insert $table_name exec testing.File_Get_ByMd5 \@md5table = \@md5table;
			select * from $table_name order by md5;
			drop table $table_name;";
	print_time("get_wl sql = ".$sql);	
	my $sth = $dbh_wl->prepare($sql);
	$sth -> execute();
	
	my @rows;
	my $result;
	
	while(@rows = $sth->fetchrow_array()) 
	{ 
		#print $rows[0].";".$rows[1].";".$rows[2].";".$rows[3].";\n";
		$md5=$rows[0];
		$sha=$rows[1];
		if ($sha eq "")
		{
			$sha = "NULL";
		}
		$timeadded_publisher = $rows[2];
		$lastchangetimezone_publisher = $rows[3];
		if ($timeadded_publisher eq "")
		{
			$timeadded_publisher="null null";
		}
		if ($lastchangetimezone_publisher eq "")
		{
			$lastchangetimezone_publisher="null null";
		}		
		$result = $md5." ".$sha." ".$timeadded_publisher." ".$lastchangetimezone_publisher." ".lc($rows[4])." ".$rows[5];
	}
	print_time("get_wl result = ".$result);	
	$sth -> finish;
	return $result;
}

sub audit_xml
{
	my $aush_message=shift;
	$parser = new XML::DOM::Parser;
	$doc = $parser->parse($aush_message);
	$parent = $doc->getDocumentElement;
	$orderNode 	= $doc->getFirstChild;
	$send_date 	= $orderNode->getAttribute( "send_date");
	$message_guid 	= $orderNode->getAttribute( "message_guid");
	$operation	= $orderNode->getElementsByTagName("operation")->item(0)->getFirstChild->getData;
	$md5	= $orderNode->getElementsByTagName("md5")->item(0)->getFirstChild->getData;
	#my $hips_polisy	= $orderNode->getElementsByTagName("hips")	->getAttribute( "policy");
	$ndeLst = $orderNode->getChildNodes();
	$numndes = $ndeLst->getLength()-1;
	print_time("audit_xml start");	
	print_time("audit_xml numndes = ".$numndes);	
	@xml_result=();
	$hips_policy="";		
	$amask_type="";		
	$file_name="";	
	$file_size="";	
	$file_regDate="";
	$file_trustedZoneLevel="";
	$userCount="";
	$firstRequestTime="";
	$trusted="";
	$lowRest="";
	$untrusted="";
	for ( $i = 0; $i <= $numndes; $i++ )
	{
	
		$nde = $ndeLst->item( $i );

		if ($nde->getNodeType() == TEXT_NODE )
		{
			print_time("audit_xml getNodeType = TEXT_NODE");			
			print_time("audit_xml getNodeType = TEXT_NODE getNodeValue = ".$nde->getNodeValue());						
			print_time("audit_xml getNodeType = TEXT_NODE getData = ".$nde->getData());									
		}

		if ($nde->getNodeType == ELEMENT_NODE)
		{
			if ($nde->getNodeName() eq "hips")
			{
				$hips_policy	= $nde->getAttributeNode ( "policy")->getValue ;
			}
			if ($nde->getNodeName() eq "file")
			{
				#$file_name	= $orderNode->getElementsByTagName("hips")->getAttribute( "name");
				#$file_size	= $orderNode->getElementsByTagName("hips")->getAttribute( "size");
				#$file_regDate	= $orderNode->getElementsByTagName("hips")->getAttribute( "regDate");
				#$file_trustedZoneLevel	= $orderNode->getElementsByTagName("hips")->getAttribute( "trustedZoneLevel");
				$atrLst_file = $nde->getAttributes;
				if ($atrLst_file)
					{ 
						$attLength_file = $atrLst_file->getLength 
					};
				if ($attLength_file)
				{
					for( my $j=0; $j<$attLength_file; $j++ )
					{
						$attNode = $atrLst_file->item($j);
						if ($attNode->getName eq "name")
						{
							$file_name	= $attNode->getValue;
						}
						if ($attNode->getName eq "size")
						{
							$file_size	= $attNode->getValue;
						}
						if ($attNode->getName eq "regDate")
						{
							$file_regDate	= $attNode->getValue;
						}
						if ($attNode->getName eq "trustedZoneLevel")
						{
							$file_trustedZoneLevel	= $attNode->getValue;
						}
					}
				}				
			}		
			if ($nde->getNodeName() eq "amask_type")
			{
				$amask_type	= $nde->getFirstChild->getData;	
			}
			if ($nde->getNodeName() eq "woc")
			{
				$ndeLst_woc = $nde->getChildNodes();
				$numndes_woc = $ndeLst_woc->getLength() - 1;
				print_time("audit_xml numndes_woc = ".$numndes_woc);					
				
				for ( $i_woc = 0; $i < $numndes_woc; $i++ )
				{
					$nde_woc = $ndeLst_woc->item( $i );				

					if ($nde_woc->getNodeType == ELEMENT_NODE)
					{										
						if ($nde_woc->getNodeName() eq "userCount")
						{
							$userCount	= $nde_woc->getNodeValue;					
						}
						if ($nde_woc->getNodeName() eq "firstRequestTime")
						{
							$firstRequestTime	= $nde_woc->getNodeValue;					
						}						
						if ($nde_woc->getNodeName() eq "groupSharing")
						{
#							$trusted	= $nde->getAttributeNode ( "trusted")->getValue ;
#							$lowRest	= $nde->getAttributeNode ( "lowRest")->getValue ;
#							$untrusted	= $nde->getAttributeNode ( "untrusted")->getValue ;
						}							
					}						
				}
			}			
		}
	}	
	print_time("audit_xml md5 = ".$md5." send_date = ".$send_date);					
	print_time("audit_xml md5 = ".$md5." message_guid = ".$message_guid);		
	print_time("audit_xml md5 = ".$md5." operation = ".$operation);		
	print_time("audit_xml md5 = ".$md5." hips_policy base64 = ".$hips_policy);
	my $hips_policy_decode = MIME::Base64::decode($hips_policy);
	my $hips_policy_bin = unpack('H*', $hips_policy_decode);	
	my $hips_policy_verdict = get_policy($hips_policy_bin);
	print_time("audit_xml md5 = ".$md5." hips_policy_bin = ".$hips_policy_bin);
	print_time("audit_xml md5 = ".$md5." hips_policy_verdict = ".$hips_policy_verdict);
	print_time("audit_xml md5 = ".$md5." amask_type = ".$amask_type);		
	print_time("audit_xml md5 = ".$md5." file_name = ".$file_name);		
	print_time("audit_xml md5 = ".$md5." file_size = ".$file_size);		
	print_time("audit_xml md5 = ".$md5." file_regDate = ".$file_regDate);		
	print_time("audit_xml md5 = ".$md5." file_trustedZoneLevel = ".$file_trustedZoneLevel);			
	$xml_result[0]=$message_guid;
	$xml_result[1]=$operation;
	$xml_result[2]=$hips_policy_bin;
	$xml_result[3]=$hips_policy_verdict;
	print_time("audit_xml md5 = ".$md5." xml_result 0 = ".$xml_result[0]);			
	print_time("audit_xml md5 = ".$md5." xml_result 1 = ".$xml_result[1]);				
	$doc->dispose;
	return @xml_result;
}

sub TaskLog_full
{
	my $dbh_audit=shift;
	my $dbh_fe=shift;	
	my $guid_audit=shift;
	my $md5_audit=shift;
	my $prefix=shift;
	my $mas_ref=shift;	
	
	my $sql_task="";
	my $sql_task_count="";
	my $frontend_id="";
	print_time("TaskLog_full start");			
	print_time("TaskLog_full guid_audit = ".$guid_audit);
	#$sql_task="select t.date,t.message_guid,t.error_message,t.message_status,t.frontend_id,t.data_flow_crc8 from TaskLog t where message_guid in ('".$guid_audit."')";
	my $sql_task_count_full="select date, message_guid, error_message, message_status, frontend_id, data_flow_crc8 from TaskLog t where message_guid in ('".$guid_audit."')";
	my $sth_task_full = $dbh_audit->prepare($sql_task_count_full);
	$sth_task_full -> execute();	
	@rows_task_full=();
	my $date;
	my $message_guid;
	my $error_message;
	my $message_status;
	my $frontend_id;
	my $data_flow_crc8;
	my $index_tasklog=0;
	while(@rows_task_full = $sth_task_full->fetchrow_array()) 
	{
		$date=$rows_task_full[0];
		$message_guid=$rows_task_full[1];
		$error_message=$rows_task_full[2];
		if ($error_message eq "")
		{
			$error_message="null";
		}
		$message_status=$rows_task_full[3];
		$frontend_id=$rows_task_full[4];
		if ($frontend_id eq "")
		{
			$frontend_id="null";
		}			
		$data_flow_crc8=$rows_task_full[5];		
		print_time("TaskLog_full row ".$date." ".$message_guid." ".$error_message." ".$message_status." ".$frontend_id." ".$data_flow_crc8);	
		@$mas_ref[$index_tasklog]=$date." ".$message_guid." ".$error_message." ".$message_status." ".$frontend_id." ".$data_flow_crc8;
		
		$index_tasklog++;
	}
	print_time("TaskLog_full rows count = ".scalar(@$mas_ref));
	$sth_task_full -> finish;	
	
}

sub TaskLog_Archive
{
	my $start_date=shift;
	my $end_date=shift;	
	my $guid_audit=shift;
	
	my $sql_task="";
	my $sql_task_count="";
	my $frontend_id="";	
	
	print_time("TaskLog_Archive start");			
	print_time("TaskLog_Archive guid_audit = ".$guid_audit);

	$sth_task_full -> finish;
	
	$sql_task_count="select top 1
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 0) status_0,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 1) status_1,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 3) status_3,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 4) status_4
					from TaskLog t ";
					"select top 1
					(select count(*) from dbo.TaskLog_Old 
							(CONVERT(datetime, '".$start_date."',120),
							CONVERT(datetime, '".$end_date."',120),
							'".$guid_audit."') t
							where t.message_status = 0) status_0,
					(select count(*) from dbo.TaskLog_Old 
							(CONVERT(datetime, '".$start_date."',120),
							CONVERT(datetime, '".$end_date."',120),
							'".$guid_audit."') t
							where t.message_status = 1) status_1,
					(select count(*) from dbo.TaskLog_Old 
							(CONVERT(datetime, '".$start_date."',120),
							CONVERT(datetime, '".$end_date."',120),
							'".$guid_audit."') t
							where t.message_status = 3) status_3,
					(select count(*) from dbo.TaskLog_Old 
							(CONVERT(datetime, '".$start_date."',120),
							CONVERT(datetime, '".$end_date."',120),
							'".$guid_audit."') t
							where t.message_status = 4) status_4
					from dbo.TaskLog t";
					
	print_time("TaskLog_Archive sql_task_count = ".$sql_task_count);
	my $sth_task = $dbh_audit->prepare($sql_task_count);
	$sth_task -> execute();
	my @rows_task=();
	my $status_0="";
	my $status_1="";
	my $status_3="";
	my $status_4="";		
	
	while(@rows_task = $sth_task->fetchrow_array()) 
	{ 
		$status_0="";
		$status_1="";
		$status_3="";	
		$status_4="";	
		$status_0=$rows_task[0];
		$status_1=$rows_task[1];
		$status_3=$rows_task[2];
		$status_4=$rows_task[3];
		#$id=$rows[0];	
		#$date=$rows_task[0];
		#$message_guid=$rows_task[1];
		#$error_message=$rows_task[2];
		#$message_status=$rows_task[3];
		#if ($rows_task[4] eq "")
		#{
		#	$frontend_id="NULL";
		#}
		#else
		#{
		#	$frontend_id=$rows_task[4];
		#}
		#$data_flow_crc8=$rows_task[5];
		#foreach(@rows)
		#{
			#print $_;
		#}
		#print "\n";	
		#print "===========================================\n";
		#print "rows_tasklog frontend_id = ".$frontend_id."\n";
		#print "rows_tasklog message_status = ".$message_status."\n";

		print_time("TaskLog_Archive rows_tasklog status_0 = ".$status_0);
		print_time("TaskLog_Archive rows_tasklog status_1 = ".$status_1);
		print_time("TaskLog_Archive rows_tasklog status_3 = ".$status_3);
		print_time("TaskLog_Archive rows_tasklog status_4 = ".$status_4);
		
		#if ($frontend_id eq "NULL")
		#{
		#	print "rows_tasklog frontend_id = ".$frontend_id."\n";
		#}
		#else 
		#{
		#	$frontend_name = frontend_name_from_db($dbh_fe,$frontend_id);
		#	print "rows_tasklog frontend_name = ".$frontend_name."\n";	
		#}
	}	
	return $status_0.";".$status_1.";".$status_3.";".$status_4.";";
}

sub TaskLog
{
	my $dbh_audit=shift;
	my $dbh_fe=shift;	
	my $guid_audit=shift;
	my $md5_audit=shift;
	my $prefix=shift;
	my $mas_ref=shift;	
	my $aush_create_date=shift;
	
	my $sql_task="";
	my $sql_task_count="";
	my $frontend_id="";	
	
	my $wl_result = get_wl($md5_audit,$dbh_wl);
		
	print_time("TaskLog start");			
	print_time("TaskLog guid_audit = ".$guid_audit);

	$sth_task_full -> finish;
	
	$sql_task_count="select top 1
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 0) status_0,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 1) status_1,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 3) status_3,
					(select count(*) from TaskLog t where message_guid in ('".$guid_audit."') and t.message_status = 4) status_4
					from TaskLog t ";
	print_time("TaskLog sql_task_count = ".$sql_task_count);
	$sth_task = $dbh_audit->prepare($sql_task_count);
	$sth_task -> execute();
	@rows_task=();
	$status_0="";
	$status_1="";
	$status_3="";
	while(@rows_task = $sth_task->fetchrow_array()) 
	{ 
		$status_0="";
		$status_1="";
		$status_3="";	
		$status_4="";	
		$status_0=$rows_task[0];
		$status_1=$rows_task[1];
		$status_3=$rows_task[2];
		$status_4=$rows_task[3];
		#$id=$rows[0];	
		#$date=$rows_task[0];
		#$message_guid=$rows_task[1];
		#$error_message=$rows_task[2];
		#$message_status=$rows_task[3];
		#if ($rows_task[4] eq "")
		#{
		#	$frontend_id="NULL";
		#}
		#else
		#{
		#	$frontend_id=$rows_task[4];
		#}
		#$data_flow_crc8=$rows_task[5];
		#foreach(@rows)
		#{
			#print $_;
		#}
		#print "\n";	
		#print "===========================================\n";
		#print "rows_tasklog frontend_id = ".$frontend_id."\n";
		#print "rows_tasklog message_status = ".$message_status."\n";

		print_time("TaskLog rows_tasklog status_0 = ".$status_0);
		print_time("TaskLog rows_tasklog status_1 = ".$status_1);
		print_time("TaskLog rows_tasklog status_3 = ".$status_3);
		print_time("TaskLog rows_tasklog status_4 = ".$status_4);
		
		#if ($frontend_id eq "NULL")
		#{
		#	print "rows_tasklog frontend_id = ".$frontend_id."\n";
		#}
		#else 
		#{
		#	$frontend_name = frontend_name_from_db($dbh_fe,$frontend_id);
		#	print "rows_tasklog frontend_name = ".$frontend_name."\n";	
		#}
	}	
	
	if (($status_0 == 0) && ($status_1 == 0) && ($status_3 == 0) && ($status_4 == 0))
	{
		print_time("call TaskLog_Archive");
		my $start_date = $format_sql->parse_datetime($aush_create_date);
		my $end_date = $format_sql->parse_datetime($aush_create_date);
		$start_date = $start_date->add(days => -1)->strftime("%Y-%m-%d %H:%M:%S");
		$end_date = $end_date->add(days => 1)->strftime("%Y-%m-%d %H:%M:%S");
		
		print_time("TaskLog aush_create_date = ".$aush_create_date);
		print_time("TaskLog start_date = ".$start_date);
		print_time("TaskLog end_date = ".$end_date);
		
		my $statuses = TaskLog_Archive($start_date,$end_date,$guid_audit);
		$status_0 = cut($statuses,"0",";");
		$status_1 = cut($statuses,"1",";");
		$status_3 = cut($statuses,"2",";");
		$status_4 = cut($statuses,"3",";");
	}
	$rows_tasklog = $sth_task->rows;
	print_time("TaskLog rows_tasklog = ".$rows_tasklog);	
	if ($rows_tasklog == 0)
	{
		print_time("TaskLog rows_tasklog = 0");			
	}
	else
	{
		if (($status_3 != 0) && ($status_1 != 0) && ($status_0 != 0))
		{
			print_file($prefix."_6", $md5_audit, $guid_audit);
			print_time("############################## Case 6 start ##############################");			
			print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
			print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
			print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
			print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);				
			print_time("############################## Case 6 end ##############################");		
			print_time("TaskLog ".$md5_audit."_audit count = ".scalar(@{$md5_audit."_audit"}));
			open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_6_.log");	
			flock($filefull,LOCK_EX);
			print_full($prefix."_6","======================================================================", $filefull);
			print_full($prefix."_6","		MD5: ".$md5_audit,$filefull);			
			foreach my $file_server (@file_servers)
			{
				if (grep/$md5_audit/,@{"fail_md5_".$file_server})
				{
					print_full($prefix."_6","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
				{
					print_full($prefix."_6","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
				{
					print_full($prefix."_6","		Server = ".$file_server,$filefull);
				}
				elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
				{
					print_full($prefix."_6","		Server = ".$file_server,$filefull);
				}			
			}				
			print_full($prefix."_6","		TIME: ".get_time(), $filefull);			
			print_full($prefix."_6","		WL = ".$wl_result, $filefull);
			#print_full($prefix."_6","----------------------------------------------------------------------");
			my $indx_audit=0;
			print_full($prefix."_6","			Audit: ".$aush_workload_guid, $filefull);
			foreach my $line (@{$md5_audit."_audit"})
			{
				my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
				print_full($prefix."_6","			Audit = ".$line,$filefull);
				my $indx_tasklog=0;
				#print_full($prefix."_6","----------------------------------------------------------------------");
				print_full($prefix."_6","		       Tasklog: ".$aush_workload_guid,$filefull);
				foreach (@$mas_ref)
				{
					my $line=@$mas_ref[$indx_tasklog];
					print_full($prefix."_6","		       Tasklog = ".$line, $filefull);
					$indx_tasklog++;
				}
				$indx_audit++;
			}	
			close($filefull);
		}	
		else
		{
			if (($status_3 == 0) && ($status_1 != 0) && ($status_0 != 0))
			{
				print_file($prefix."_5", $md5_audit, $guid_audit);
				print_time("############################## Case 5 start ##############################");			
				print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
				print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
				print_time("TaskLog rows_tasklog status_0 = ".$status_0);	
				print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
				print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);						
				print_time("############################## Case 5 end ##############################");			
				open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_5_.log");	
				flock($filefull,LOCK_EX);				
				print_full($prefix."_5","======================================================================", $filefull);
				print_full($prefix."_5","		MD5: ".$md5_audit,$filefull);				
				foreach my $file_server (@file_servers)
				{
					if (grep/$md5_audit/,@{"fail_md5_".$file_server})
					{
						print_full($prefix."_5","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
					{
						print_full($prefix."_5","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
					{
						print_full($prefix."_5","		Server = ".$file_server,$filefull);
					}
					elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
					{
						print_full($prefix."_5","		Server = ".$file_server,$filefull);
					}			
				}					
				print_full($prefix."_5","		TIME: ".get_time(), $filefull);			
				print_full($prefix."_5","		WL = ".$wl_result, $filefull);
				#print_full($prefix."_5","----------------------------------------------------------------------");
				my $indx_audit=0;
				print_full($prefix."_5","			Audit: ".$aush_workload_guid, $filefull);
				foreach my $line (@{$md5_audit."_audit"})
				{
					my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
					print_full($prefix."_5","			Audit = ".$line,$filefull);
					my $indx_tasklog=0;
					#print_full($prefix."_5","----------------------------------------------------------------------");
					print_full($prefix."_5","		       Tasklog: ".$aush_workload_guid,$filefull);
					foreach (@$mas_ref)
					{
						my $line=@$mas_ref[$indx_tasklog];
						print_full($prefix."_5","		       Tasklog = ".$line, $filefull);
						$indx_tasklog++;
					}
					$indx_audit++;
				}		
				close($filefull);				
			}
			else
			{
				if (($status_1 == 0)&& ($status_0 != 0))
				{
					print_file($prefix."_4", $md5_audit, $guid_audit);
					print_time("############################## Case 4 start ##############################");			
					print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
					print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
					print_time("TaskLog rows_tasklog status_0 = ".$status_0);	
					print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
					print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);							
					print_time("############################## Case 4 end ##############################");
					open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_4_.log");	
					flock($filefull,LOCK_EX);					
					print_full($prefix."_4","======================================================================", $filefull);
					print_full($prefix."_4","		MD5: ".$md5_audit,$filefull);					
					foreach my $file_server (@file_servers)
					{
						if (grep/$md5_audit/,@{"fail_md5_".$file_server})
						{
							print_full($prefix."_4","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
						{
							print_full($prefix."_4","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
						{
							print_full($prefix."_4","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
						{
							print_full($prefix."_4","		Server = ".$file_server,$filefull);
						}			
					}						
					print_full($prefix."_4","		TIME: ".get_time(), $filefull);			
					print_full($prefix."_4","		WL = ".$wl_result, $filefull);
					#print_full($prefix."_4","----------------------------------------------------------------------");
					my $indx_audit=0;
					print_full($prefix."_4","			Audit: ".$aush_workload_guid, $filefull);
					foreach my $line (@{$md5_audit."_audit"})
					{
						my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
						print_full($prefix."_4","			Audit = ".$line,$filefull);
						my $indx_tasklog=0;
						#print_full($prefix."_4","----------------------------------------------------------------------");
						print_full($prefix."_4","		       Tasklog: ".$aush_workload_guid,$filefull);
						foreach (@$mas_ref)
						{
							my $line=@$mas_ref[$indx_tasklog];
							print_full($prefix."_4","		       Tasklog = ".$line, $filefull);
							$indx_tasklog++;
						}
						$indx_audit++;
					}
					close($filefull);					
				}
				elsif (($status_3 == 0) && ($status_1 == 0) && ($status_0 == 0))
				{
					print_file($prefix."_3", $md5_audit, $guid_audit);
					print_time("############################## Case 3 start ##############################");			
					print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
					print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
					print_time("TaskLog rows_tasklog status_0 = ".$status_0);	
					print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
					print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);							
					print_time("############################## Case 3 end ##############################");		
					open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_3_.log");	
					flock($filefull,LOCK_EX);					
					print_full($prefix."_3","======================================================================", $filefull);
					print_full($prefix."_3","		MD5: ".$md5_audit,$filefull);					
					foreach my $file_server (@file_servers)
					{
						if (grep/$md5_audit/,@{"fail_md5_".$file_server})
						{
							print_full($prefix."_3","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
						{
							print_full($prefix."_3","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
						{
							print_full($prefix."_3","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
						{
							print_full($prefix."_3","		Server = ".$file_server,$filefull);
						}			
					}						
					print_full($prefix."_3","		TIME: ".get_time(), $filefull);			
					print_full($prefix."_3","		WL = ".$wl_result, $filefull);
					#print_full($prefix."_3","----------------------------------------------------------------------");
					my $indx_audit=0;
					print_full($prefix."_3","			Audit: ".$aush_workload_guid, $filefull);
					foreach my $line (@{$md5_audit."_audit"})
					{
						my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
						print_full($prefix."_3","			Audit = ".$line,$filefull);
						my $indx_tasklog=0;
						#print_full($prefix."_3","----------------------------------------------------------------------");
						print_full($prefix."_3","		       Tasklog: ".$aush_workload_guid,$filefull);
						foreach (@$mas_ref)
						{
							my $line=@$mas_ref[$indx_tasklog];
							print_full($prefix."_3","		       Tasklog = ".$line, $filefull);
							$indx_tasklog++;
						}
						$indx_audit++;
					}		
					close($filefull);
				}
				elsif (($status_4 != 0) && ($status_1 != 0) && ($status_0 == 0) && ($status_3 != 0))
				{
					print_file($prefix."_8", $md5_audit, $guid_audit);
					print_time("############################## Case 8 start ##############################");			
					print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
					print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
					print_time("TaskLog rows_tasklog status_0 = ".$status_0);	
					print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
					print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);							
					print_time("############################## Case 8 end ##############################");	
					open ($filefull,">> ".$pathlogs."/file_analyzefull_".$prefix."_8_.log");	
					flock($filefull,LOCK_EX);					
					print_full($prefix."_8","======================================================================", $filefull);
					print_full($prefix."_8","		MD5: ".$md5_audit,$filefull);					
					foreach my $file_server (@file_servers)
					{
						if (grep/$md5_audit/,@{"fail_md5_".$file_server})
						{
							print_full($prefix."_8","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnotbutexist_md5_".$file_server})
						{
							print_full($prefix."_8","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"ok_md5_".$file_server})
						{
							print_full($prefix."_8","		Server = ".$file_server,$filefull);
						}
						elsif (grep/$md5_audit/,@{"mustnot_md5_".$file_server})
						{
							print_full($prefix."_8","		Server = ".$file_server,$filefull);
						}			
					}						
					print_full($prefix."_8","		TIME: ".get_time(), $filefull);			
					print_full($prefix."_8","		WL = ".$wl_result, $filefull);
					#print_full($prefix."_8","----------------------------------------------------------------------");
					my $indx_audit=0;
					print_full($prefix."_8","			Audit: ".$aush_workload_guid, $filefull);
					foreach my $line (@{$md5_audit."_audit"})
					{
						my $aush_workload_guid=cut(${$md5_audit."_audit"}[$indx_audit],"0"," ");
						print_full($prefix."_8","			Audit = ".$line,$filefull);
						my $indx_tasklog=0;
						#print_full($prefix."_8","----------------------------------------------------------------------");
						print_full($prefix."_8","		       Tasklog: ".$aush_workload_guid,$filefull);
						foreach (@$mas_ref)
						{
							my $line=@$mas_ref[$indx_tasklog];
							print_full($prefix."_8","		       Tasklog = ".$line, $filefull);
							$indx_tasklog++;
						}
						$indx_audit++;
					}		
					close($filefull);
				}				
				else
				{
					#print_file($prefix."_7", $md5_audit);
					#print_time("############################## Case 7 start ##############################");			
					print_time("############################## EXCEPT start ##############################");
					print_time("TaskLog rows_tasklog status_3 = ".$status_3);	
					print_time("TaskLog rows_tasklog status_1 = ".$status_1);	
					print_time("TaskLog rows_tasklog status_0 = ".$status_0);	
					print_time("TaskLog rows_tasklog md5_audit = ".$md5_audit);	
					print_time("TaskLog rows_tasklog guid_audit = ".$guid_audit);							
					print_time("############################## EXCEPT end ##############################");	
				}
			}
		}
	}
	print "===========================================\n";	
}

sub get_policy
{
	my $policy_str=shift;
	#my $policy_str_final=shift;
	my $verdict;
	
	my @policy_mas=();
	while ($policy_str=~ m/([a-f0-9]{1})/g) 
	{
		push @policy_mas, $1;
	}

	my $indx=1;
	foreach my $line (@policy_mas)
	{
		#print "line ".$indx." = ".$line." ";
		$indx++;
	}
	
	if  (($policy_mas[9] eq "3") && ($policy_mas[8] eq "0"))
	{
		#print "verdict = bad";
		#push @$policy_str_final, "Verdict : <font color=\"red\"><b>bad</b></font>";
		$verdict="bad";
	}
	elsif (($policy_mas[9] eq "f") && ($policy_mas[8] eq "f"))
	{
		#print "verdict = unknown";
		#push @$policy_str_final, "Verdict : <font color=\"blue\"><b>unknown</b></font>";
		$verdict="unknown";
	}
	elsif (($policy_mas[9] eq "0") && ($policy_mas[8] eq "0"))
	{
		#print "verdict = good";
		#push @$policy_str_final, "Verdict : <font color=\"green\"><b>good</b></font>";
		$verdict="good";
	}
	return $verdict;
}

sub frontend_db_connect
{
	print_time("frontend_db_connect start");	
	my ($host,$port,$instance,$database,$user,$pass) = ("KSNSQL","1433","SQLEXPRESS","frontend_test","KL\\kalistratov","Y6UHYziF");
	#my $user = q/KL\\kalistratov/;
	#my $pass = q/Y6UHYziF/;
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;	
	my $DBI;
	print_time("frontend_db_connect DBI connect");
	$dbh_fe = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
		{
			PrintError  => 0,
			HandleError => \&handle_error,
		}
		) or handle_error($DBI->errstr);
	print_time("frontend_db_connect dbh syb_date_fmt");
	$dbh_fe->syb_date_fmt('ISO');		
	print_time("frontend_db_connect return dbh");	
	return $dbh_fe;	
	
}

sub frontend_name_from_db
{
	#$dbh_fe = frontend_db_connect();
	$dbh_fe=shift;	
	$frontend_id=shift;
	$sql_fe="";
	$host="";
	print_time("frontend_name_from_db start");	
	print_time("frontend_name_from_db frontend_id = ".$frontend_id);
	$sql_fe="select * from Frontend where id in ('".$frontend_id."')";
	print_time("frontend_name_from_db sql_fe = ".$sql_fe);
	my $sth_fe = $dbh_fe->prepare($sql_fe);
	$sth_fe -> execute();
	my $rows_audits;
	my @rows_fe;

	while(@rows_fe = $sth_fe->fetchrow_array()) 
	{ 
		$id=$rows_fe[0];	
		$host=$rows_fe[1];
		$username=$rows_fe[2];
		$password=$rows_fe[3];
		$use_proxy=$rows_fe[4];
		$down_since=$rows_fe[5];
		#foreach(@rows)
		#{
			#print $_;
		#}
		#print "\n";	
		#print "===========================================\n";
		#print "rows_frontend_db id = ".$id."\n";
		#print "rows_frontend_db host = ".$host."\n";
		#print "===========================================\n";
		if ($id == $frontend_id)
		{
			return $host;
		}
	}	
	$rows_frontend_db = $sth_fe->rows;
	print_time("frontend_name_from_db rows_frontend_db = ".$rows_frontend_db);		
	
}

sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";

	unlink ("/file/file_sql_debug.html");
	open(file_sql_debug,"> /file/file_sql_debug.html");
	open(log_server_sqlfail,">> /file/logs/file_sqlfail_.log");
	print log_server_sqlfail "MD5 request fail = handle error\n";	
	print file_sql_debug "SQL Fail message = ".$message."<br>\n";
	print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
	print file_sql_debug "script = file_monitor.analyze_results.all hips<br>\n";
	print log_server_sqlfail "script = file_monitor.analyze_results.all hips<br>\n";
	$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
	print "mail_email_addreses = ".$mail_email_addreses."\n";
	$subject="File SHA256. Monitoring test - Consistency. Debug info - SQL Fail";
	$type="html";
	system("/export/controller/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
	close(file_sql_debug);
	close(log_server_sqlfail);
	unlink ("/file/file_sql_debug.html");	
	
    exit; #stop the program
}

sub handle_error_wl {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";

	unlink ("/file/file_sql_debug_wl.html");
	open(file_sql_debug_wl,"> /file/file_sql_debug_wl.html");
	open(log_server_sqlfail_wl,">> /file/logs/file_sqlfail_.log");
	print log_server_sqlfail_wl "MD5 request fail = handle error\n";	
	print file_sql_debug_wl "SQL Fail message = ".$message."<br>\n";
	print log_server_sqlfail_wl "SQL Fail message = ".$message."<br>\n";
	print file_sql_debug_wl "script = file_monitor.analyze_results.wl<br>\n";
	print log_server_sqlfail_wl "script = file_monitor.analyze_results.wl<br>\n";
	$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
	print "mail_email_addreses = ".$mail_email_addreses."\n";
	$subject="File SHA256. Monitoring test - Consistency. Debug info - SQL Fail";
	$type="html";
	system("/export/controller/controller.mail_send.pl /file/file_sql_debug_wl.html \"$mail_email_addreses\" \"$subject\" \"html\"");
	close(file_sql_debug_wl);
	close(log_server_sqlfail_wl);
	unlink ("/file/file_sql_debug_wl.html");	
	
    exit; #stop the program
}


sub create_all_mas
{
	$type_mas=shift;
	*mas=shift;
	*file_servers=shift;
	@result_mas=();
	foreach $file_server (@file_servers)
	{
		print "file_server = ".$file_server." \n";	
		foreach(@{$type_mas."_mas_".$file_server})
		{
			print $type_mas."_mas_".$file_server." \n";
			if (grep(!/$_/,@result_mas))
			{
				push (@result_mas,$_);
			}
		}
	}
	return @result_mas;
}
sub get_cut_from_mas
{
	$number_mas=shift;
	$delimeter_mas=shift;
	*mas_mas=shift;
	@return_mas=();
	my $i=0;
	foreach(@mas_mas)
	{
		$return_mas[$i]=cut($_,$number_mas,$delimeter_mas);
		if ($i == $analyze_limit)
		{
			last;
		}
		$i++;
	}
	return @return_mas;
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
sub print_time
{
	#my $file_=shift;
	my $text=shift;
	#$path_print_time="/export/file/monitor_consistency/_bin";
	
	open (debug_file,">> ".$pathlogs."/file_analyzdebug_.log");	
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print debug_file "[DEBUG] [".$datetime_now."] [".$text."]\n";
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
	close(debug_file);
}
sub print_file
{
	my $type=shift;
	my $text=shift;
	my $guid=shift;
	#$path_print_file="/export/file/monitor_consistency/_bin";
	
	open (file,">> ".$pathlogs."/file_analyze_".$type."_.log");	
	open (file_analyzed_dic,">> ".$pathlogs."/file_analyzeddic_.log");	
	print file $text."\n";
	print file_analyzed_dic "md5 = ".$text." type = ".$type." guid = ".$guid."\n";
	close(file);
	close(file_analyzed_dic);
}
sub print_full
{
	my $type=shift;
	my $text=shift;
	my $filefull=shift;
	
	#open (filefull,">> ".$pathlogs."/file_analyzefull_".$type."_.log");	
	print_time("[PRINT FULL] [".$type."] [".$text);
	print $filefull $text."\n";
	#close(filefull);
}
sub print_fulldic
{
	my $text=shift;
	open (filefull,">> ".$pathlogs."/file_analyzefulldic_.log");	
	print_time("[PRINT FULL DIC] [".$text);
	print filefull $text."\n";
	close(filefull);
}