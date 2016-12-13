#!/usr/bin/perl

use Time::localtime;
#use strict;
use v5.10;
use Time::localtime;
#use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;

#$path=seach_params2('/file/parameters.dat','path');
#$packet_size=seach_params2('/file/parameters.dat','packet_file_size');
$path=shift;
$pathlogs=shift;
$packet_size=shift;
$filename=shift;
$type_result=shift;
print "path = ".$path."\n";
print "pathlogs = ".$pathlogs."\n";
print "packet_size = ".$packet_size."\n";
print "filename = ".$filename."\n";
print "type_result = ".$type_result."\n";

#opendir(DIR, $path."/logs");
opendir(DIR, $pathlogs);

#opendir(DIR, "/export/test");
@FILES= readdir(DIR); 
#@logs_fail=grep(/_fail_/,@FILES);
#@logs_ok=grep(/_ok_/,@FILES);
@logs_mustnot=grep(/_mustnot_/,@FILES);
#print "count logs_mustnot = ".scalar(@logs_mustnot)."\n";
@logs_error=grep(/_errorlog_/,@FILES);
@mas=();
$indx_mas=0;

open (logfile_analyzedic,$pathlogs."/file_analyzeddic_.log");
@analyzedic_all=<logfile_analyzedic>;
print "count analyzedic\n";
print "count analyzedic_all = ".scalar(@analyzedic_all)."\n";
@analyzedic = grep (!/notfound/,@analyzedic_all);
print "count analyzedic = ".scalar(@analyzedic)."\n";
open (logfile_fail_notfound,$pathlogs."/file_analyze_fail_notfound_.log");
@analyze_fail_notfound=<logfile_fail_notfound>;
$count_analyze_fail_notfound=scalar(@analyze_fail_notfound);
print "count count_analyze_fail_notfound = ".$count_analyze_fail_notfound."\n";
open (logfile_exist_notfound,$pathlogs."/file_analyze_exist_notfound_.log");
@analyze_exist_notfound=<logfile_exist_notfound>;
$count_analyze_exist_notfound=scalar(@analyze_exist_notfound);
print "count count_analyze_exist_notfound = ".$count_analyze_exist_notfound."\n";
opendir(resultlogsdir, $pathlogs);
@resultlogsall= readdir(resultlogsdir); 
@resultlogs=grep(/_analyze_/,@resultlogsall);
@types=("1_1","1_2","1_3","1_4","1_5","1_6","1_7","1_8","1_9","2_1","2_2","2_3","2_4","2_5","2_6","2_7","2_8","2_9");
foreach(@types)
{
	${"mas_".$_."_count"}=0;
}

foreach my $resultlog (@resultlogs)
{
	chomp($resultlog);
	$type=cut($resultlog,"2","_")."_".cut($resultlog,"3","_");
	print "type analyze file = ".$type."\n";
	$analyzefile="file_".$type;
	open($analyzefile,$pathlogs."/".$resultlog);
	@{"mas_".$type}=<$analyzefile>;
	${"mas_".$type."_count"}=scalar(@{"mas_".$type});
	print "count mas_".$type." = ".${"mas_".$type."_count"}."\n";
}

close(logfile_analyzedic);
close(logfile_fail_notfound);
close(logfile_exist_notfound);

open(file_servers,$path."/file_servers.dat");
@file_servers_unsort=<file_servers>;
@file_servers=sort(@file_servers_unsort);
my $count_servers=scalar(@file_servers);
foreach(@file_servers)
{
	print "=================================\n";
	chomp $_;
	$file_server=$_;
	$md5_fail_analyzed=0;
	$md5_mustnotbutexist_analyzed=0;
	print "file_server = ".$file_server."\n";
	if ($file_server ne "")
	{
		$file_server_name=seach_params2($path."/hostsdic.dat",$file_server);
		print "file_server_name = ".$file_server_name."\n";		
		#open (logfile_all,$path."/logs/file_".$file_server.".log");
		open (logfile_all,$pathlogs."/file_".$file_server.".log");
		@logfile_all=<logfile_all>;
		@rows_all=grep(/verdict_publisher =/,@logfile_all);
		if ($type_result eq "agregate")
		{
			print "type_result = ".$type_result."\n";
			open (logfile_fail,$pathlogs."/file_fail_".$file_server.".log");
			@logfile_fail=<logfile_fail>;			
			@rows_fail=grep(/- Fail/,@logfile_fail);
			print "count rows_fail = ".scalar(@rows_fail)."\n";
			#chomp $rows_fail[0];
			#print "row 0 rows_fail = ".$rows_fail[0]."\n";
			foreach $md5_fail_row (@rows_fail)
			{
				chomp($md5_fail_row);
				$md5_fail=cut($md5_fail_row,"2"," ");
				if (grep (/$md5_fail/, @analyzedic))
				{
					print "md5_fail = ".$md5_fail."\n";
					$md5_fail_analyzed++;
				}
			}
		}
		elsif ($type_result eq "normal")
		{
			print "type_result = ".$type_result."\n";
			@rows_fail=grep(/- Fail/,@logfile_all);
			print "count rows_fail = ".scalar(@rows_fail)."\n";
			#chomp $rows_fail[0];
			#print "row 0 rows_fail = ".$rows_fail[0]."\n";
			foreach $md5_fail_row (@rows_fail)
			{
				chomp($md5_fail_row);
				$md5_fail=cut($md5_fail_row,"2"," ");
				if (grep (/$md5_fail/, @analyzedic))
				{
					print "md5_fail = ".$md5_fail."\n";
					$md5_fail_analyzed++;
				}
			}			
		}
		else
		{
			print "type_result = ".$type_result."\n";		
		}
		@rows_good_bad=grep(/verdict_publisher = good verdict_server = bad/,@logfile_all);
		@rows_bad_good=grep(/verdict_publisher = bad verdict_server = good/,@logfile_all);
		@rows_ok=grep(/- OK/,@logfile_all);		
		$count_all=scalar(@rows_all);		
		$count_fail=scalar(@rows_fail);		
		$count_ok=scalar(@rows_ok);				
		$count_good_bad=scalar(@rows_good_bad);				
		$count_bad_good=scalar(@rows_bad_good);	
		print "count_all = ".$count_all."\n";		
		print "count_ok = ".$count_ok."\n";
		print "count_fail = ".$count_fail."\n";		
		if($count_all eq "")
		{
			$count_all=0;
		}
		if($count_ok eq "")
		{
			$count_ok=0;
		}
		if($count_fail eq "")
		{
			$count_fail=0;
		}		
		close(logfile_all);
		
		#open (logfile_error,$path."/logs/file_errorlog_".$file_server.".log");		
		open (logfile_error,$pathlogs."/file_errorlog_".$file_server.".log");
		@logfile_error=<logfile_error>;
		@rows_error=grep(/MD5 =/,@logfile_error);
		my $count_error;
		$count_error=scalar(@rows_error);	
		if($count_error eq "")
		{
			$count_error=0;
		}
		if (grep {/unreachable/} @logfile_error) 
		{
			$count_error="unreachable";
		}			
		if (grep {/servicedown/} @logfile_error) 
		{
			$count_error="servicedown";
		}					
	
		print "count_error = ".$count_error."\n";	
		
		##open (logfile_mustnot,$path."/logs/file_mustnot_".$file_server.".log");
		#open (logfile_mustnot,$pathlogs."/file_mustnot_".$file_server.".log");
		#@logfile_mustnot=<logfile_mustnot>;
		#@rows_mustnot=grep(/md5_mas = /,@logfile_mustnot);		
		#$count_mustnot=scalar(@rows_mustnot);	
		#if($count_mustnot eq "")
		#{
		#	$count_mustnot=0;
		#}
		#print "count_mustnot = ".$count_mustnot."\n";	

		#open (logfile_mustnotbutexist,$path."/logs/file_mustnotbutexist_".$file_server.".log");
		open (logfile_mustnotbutexist,$pathlogs."/file_mustnotbutexist_".$file_server.".log");
		@logfile_mustnotbutexist=<logfile_mustnotbutexist>;
		@rows_mustnotbutexist=grep(/md5_mas = /,@logfile_mustnotbutexist);		
		foreach my $md5_mustnotbutexist_row (@rows_mustnotbutexist)
		{
			chomp($md5_mustnotbutexist_row);
			$md5_mustnotbutexist=cut($md5_mustnotbutexist_row,"2"," ");			
			if (grep (/$md5_mustnotbutexist/, @analyzedic))
			{
				$md5_mustnotbutexist_analyzed++;
			}
		}				
		$count_mustnotbutexist=scalar(@rows_mustnotbutexist);	
		if($count_mustnotbutexist eq "")
		{
			$count_mustnotbutexist=0;
		}
		print "count_mustnotbutexist = ".$count_mustnotbutexist."\n";			
##############################################################################################		
		##open (logfile_sqlfail,$path."/logs/file_sqlfail_".$file_server.".log");
		#open (logfile_sqlfail,$pathlogs."/file_sqlfail_.log");
		#@logfile_sqlfail=<logfile_sqlfail>;
		#@rows_sqlfail=grep(/MD5 request fail/,@logfile_sqlfail);		
		#$count_sqlfail=scalar(@rows_sqlfail);	
		#if($count_sqlfail eq "")
		#{
		#	$count_sqlfail=0;
		#}
		#print "count_sqlfail = ".$count_sqlfail."\n";			
##############################################################################################
		my $count_mustnot=getrowscount("md5_mas = ","mustnot",$file_server);	
		my $count_sqlfail=getrowscount("MD5 request fail","sqlfail",$file_server);
		my $count_sqlfail_general=getrowscount("MD5 request fail","sqlfail","");
		my $filedublicate=getrowscount("md5_mas = ","filedublicate",$file_server);	
		my $verdictdublicate=getrowscount("md5_mas = ","verdictdublicate",$file_server);
		my $notdublicate=getrowscount("md5_mas = ","notdublicate",$file_server);
##############################################################################################

		
		$file_server_type=seach_params2($path."/file_servers_hostsdesc.dat",$file_server_name);
		$name_type=seach_params2("/file/file_servers.dic",$file_server_name);
		$mas[$indx_mas][0]=$file_server;
		$mas[$indx_mas][1]=$file_server_name;
		$mas[$indx_mas][2]=$count_all;
		$mas[$indx_mas][3]=$count_ok;
		$mas[$indx_mas][4]=$count_fail;
		$mas[$indx_mas][5]=$count_error;
		$mas[$indx_mas][6]=$count_mustnot;
		$mas[$indx_mas][7]=$count_mustnotbutexist;
		$mas[$indx_mas][8]=$count_good_bad+$count_bad_good;
		$mas[$indx_mas][9]=$file_server_type;
		$mas[$indx_mas][10]=$name_type;
		$mas[$indx_mas][11]=$count_sqlfail;
		$mas[$indx_mas][12]=$md5_fail_analyzed;
		$mas[$indx_mas][13]=$md5_mustnotbutexist_analyzed;
		$mas[$indx_mas][14]=$filedublicate;
		$mas[$indx_mas][15]=$verdictdublicate;
		$mas[$indx_mas][16]=$notdublicate;
		$mas[$indx_mas][17]=$count_sqlfail_general;
		$indx_mas++;		
	
	}
}

create_html($path,$filename,*mas);

#$mail_email_addreses=seach_params2('/export/file/analyze/compare_server_to_publisher/parameters.dat',"mail_email_addreses");		
#my $subject="File. Analyze. Compare_server_to_publisher";
#system("/export/controller/controller.mail_send.pl /export/file/analyze/compare_server_to_publisher/results.html \"$mail_email_addreses\" \"$subject\" \"html\"");
sub getrowscount
{
	my $search_string=shift;
	my $log_suffix=shift;
	my $file_server=shift;
	my $count=0;
	open (logfile,$pathlogs."/file_".$log_suffix."_".$file_server.".log");
	my @logfile=<logfile>;
	my @rows=grep(/$search_string/,@logfile);			
	$count=scalar(@rows);	
	if($count eq "")
	{
		$count=0;
	}
	print "[getrowscount][".$log_suffix."] count = ".$count."\n";
	return $count;
	close(logfile);
}

sub create_html
{
	my $path=shift;
	my $filename=shift;
	*mas=shift;
	$indx_mas_html=0;
	unlink($path."/".$filename.".html");
	open($res,"> ".$path."/".$filename.".html");
	print $res "<html>\n";	
	print $res "<br><table cols=10 border=1 style=\"word-wrap: break-word;\" width=100%>\n";
	print $res "<tr><td><b>Server IP</b></td><td><b>Server name</b></td><td><b>Name Type</b></td><td><b>All requests</b></td><td><b>Should be on FE, but there is not</b></td><td><b>Should NOT be on FE, but exists</b></td><td><b>WL: File dublicates</b></td><td><b>WL: Verdicts Questions</b></td><td><b>Failuries like: good<->bad</b></td><td><b>FE Response Failure</b></td><td><b>WL Fails</b></td></tr>\n";
	
	my $zabbix_server=seach_params2('/file/parameters.dat','zabbix_server');
	my $digit;
	my $sql_error;
	my $fe_error;
	my $zabbix_consistency_total_min;
	my $zabbix_consistency_total_max;
	my $zabbix_consistency_total;
	
	foreach (@mas)
	{
		#$all_requests=$mas[$indx_mas_html][2] + $mas[$indx_mas_html][6] + $mas[$indx_mas_html][7] + $mas[$indx_mas_html][5]*$packet_size + $mas[$indx_mas_html][11]*$packet_size;
		if ($type_result eq "agregate")
		{
			$all_requests=$packet_size;
		}
		else
		{
			$all_requests=$mas[$indx_mas_html][2] + $mas[$indx_mas_html][6] + $mas[$indx_mas_html][7] +  $mas[$indx_mas_html][16];
		}
		print $res "<tr><td>".$mas[$indx_mas_html][0]."</td>\n";
		print $res "<td>".$mas[$indx_mas_html][1]."</td>\n";
		
		print $res "<td>".$mas[$indx_mas_html][10]."</td>\n";
		if ($all_requests == 0)
		{
			print $res "<td><font color=\"red\">".$all_requests."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$all_requests."</font></td>\n";
		}
		if ($mas[$indx_mas_html][4] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][4]."</font> / <font color=\"blue\">".$mas[$indx_mas_html][12]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][4]."</font></td>\n";
		}
		if ($mas[$indx_mas_html][7] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][7]."</font> / <font color=\"blue\">".$mas[$indx_mas_html][13]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][7]."</font></td>\n";
		}
		
		if ($mas[$indx_mas_html][14] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][14]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][14]."</font></td>\n";
		}
		if ($mas[$indx_mas_html][15] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][15]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][15]."</font></td>\n";
		}
		
		
		if ($mas[$indx_mas_html][8] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][8]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][8]."</font></td>\n";
		}
		if ($mas[$indx_mas_html][5] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][5]."</font></td>\n";
		}
		elsif ($mas[$indx_mas_html][5] eq "unreachable")
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][5]."</font></td>\n";
		}
		elsif ($mas[$indx_mas_html][5] eq "servicedown")
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][5]."</font></td>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][5]."</font></td>\n";
		}
		if ($mas[$indx_mas_html][11] > 0)
		{
			print $res "<td><font color=\"red\">".$mas[$indx_mas_html][11]."</font></td></tr>\n";
		}
		else
		{
			print $res "<td><font color=\"green\">".$mas[$indx_mas_html][11]."</font></td></tr>\n";
		}
		if ($type_result eq "normal")
		{
			#$digit=100 - ((100*($mas[$indx_mas_html][4] + $mas[$indx_mas_html][7]))/$all_requests);
			#$digit2=($all_requests - ($mas[$indx_mas_html][4] + $mas[$indx_mas_html][7]))*0.01;
			$sql_error=$mas[$indx_mas_html][11];
			$fe_error=$mas[$indx_mas_html][5];
			#zabbix_send($zabbix_server,"file.consistency.total",cut($mas[$indx_mas_html][1],"0","."),$digit);
			
			$zabbix_consistency_total = $all_requests - ($mas[$indx_mas_html][4] + $mas[$indx_mas_html][7] + $mas[$indx_mas_html][14] + $mas[$indx_mas_html][15]);
			$zabbix_consistency_total_max = 100000;
			$zabbix_consistency_files_mustnot = $mas[$indx_mas_html][4];
			$zabbix_consistency_files_mustnotbutexist = $mas[$indx_mas_html][7];
			$zabbix_consistency_wl_files = $mas[$indx_mas_html][14];
			$zabbix_consistency_wl_verdicts = $mas[$indx_mas_html][15];
			$zabbix_consistency_sql_error = $mas[$indx_mas_html][11];
			$zabbix_consistency_sql_error_general = $mas[$indx_mas_html][17];
			$zabbix_consistency_files_all = $mas[$indx_mas_html][4] + $mas[$indx_mas_html][7];
			
			#$zabbix_consistency_total_min = $all_requests - (2*($mas[$indx_mas_html][4] + $mas[$indx_mas_html][7])) - 3 - (($all_requests - $zabbix_consistency_total)/2);
			$zabbix_consistency_total_min = $all_requests - 4 - (($all_requests - $zabbix_consistency_total)/2);
			print "zabbix_consistency_total_min 1 = ".$zabbix_consistency_total_min."\n";			
			if ($zabbix_consistency_total_min < 0)
			{
				$zabbix_consistency_total_min = 0;
			}
			
			print "zabbix server = ".$zabbix_server."\n";			
			print "server = ".$mas[$indx_mas_html][1]."\n";
			print "zabbix_consistency_total = ".$zabbix_consistency_total."\n";
			print "zabbix_consistency_total_max = ".$zabbix_consistency_total_max."\n";
			print "zabbix_consistency_total_min = ".$zabbix_consistency_total_min."\n";
			print "zabbix_consistency_files_mustnot = ".$zabbix_consistency_files_mustnot."\n";
			print "zabbix_consistency_files_mustnotbutexist = ".$zabbix_consistency_files_mustnotbutexist."\n";
			print "zabbix_consistency_wl_files = ".$zabbix_consistency_wl_files."\n";
			print "zabbix_consistency_wl_verdicts = ".$zabbix_consistency_wl_verdicts."\n";
			print "zabbix_consistency_sql_error = ".$zabbix_consistency_sql_error."\n";
			print "zabbix_consistency_sql_error_general = ".$zabbix_consistency_sql_error_general."\n";
			print "zabbix_consistency_files_all = ".$zabbix_consistency_files_all."\n";
			
			zabbix_send($zabbix_server,"file.consistency.total",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_total*0.01);
			zabbix_send($zabbix_server,"file.consistency.total.max",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_total_max*0.01);
			zabbix_send($zabbix_server,"file.consistency.total.min",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_total_min*0.01);			
			zabbix_send($zabbix_server,"file.consistency.files.mustnot",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_files_mustnot);
			zabbix_send($zabbix_server,"file.consistency.files.mustnotbutexist",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_files_mustnotbutexist);
			zabbix_send($zabbix_server,"file.consistency.files.wl_files",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_wl_files);
			zabbix_send($zabbix_server,"file.consistency.files.wl_verdicts",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_wl_verdicts);
			zabbix_send($zabbix_server,"file.consistency.files.all",cut($mas[$indx_mas_html][1],"0","."),$zabbix_consistency_files_all);
			
			#zabbix_send($zabbix_server,"file.consistency.total",cut($mas[$indx_mas_html][1],"0","."),$digit2);
			if ($zabbix_consistency_sql_error_general > 0)
			{
				zabbix_send($zabbix_server,"file.consistency.sql_error",cut($mas[$indx_mas_html][1],"0","."),1000);
			}
			else
			{
				if ($sql_error > 0)
				{
					zabbix_send($zabbix_server,"file.consistency.sql_error",cut($mas[$indx_mas_html][1],"0","."),$sql_error*10);
				}
				else
				{
					zabbix_send($zabbix_server,"file.consistency.sql_error",cut($mas[$indx_mas_html][1],"0","."),0);
				}
			}
			if ($fe_error > 0)
			{
				zabbix_send($zabbix_server,"file.consistency.fe_error",cut($mas[$indx_mas_html][1],"0","."),$fe_error*10);
			}
			elsif ($fe_error eq "unreachable")
			{
				zabbix_send($zabbix_server,"file.consistency.unreachable",cut($mas[$indx_mas_html][1],"0","."),1000);
			}
			elsif ($fe_error eq "servicedown")
			{
				zabbix_send($zabbix_server,"file.consistency.servicedown",cut($mas[$indx_mas_html][1],"0","."),1000);
			}			
			else
			{
				zabbix_send($zabbix_server,"file.consistency.fe_error",cut($mas[$indx_mas_html][1],"0","."),0);
				zabbix_send($zabbix_server,"file.consistency.unreachable",cut($mas[$indx_mas_html][1],"0","."),0);
				zabbix_send($zabbix_server,"file.consistency.servicedown",cut($mas[$indx_mas_html][1],"0","."),0);
			}			
		}
		
		$indx_mas_html++;
	}
	
	print $res "</table>\n";		
	print "create_analyze_html start\n";		
	create_analyze_html($res);
	print "create_analyze_html end\n";		
	print $res "</html>\n";	
	print $res "<br>Servers count = ".$count_servers." <br>\n";
}
sub create_analyze_html
{
	$res=shift;
	print $res "<br><b>Analyzed MD5s</b><br><br>\n";		
	print $res "<table cols=5 border=1 style=\"word-wrap: break-word;\">\n";		
	print $res "<tr><td><b>ID 1st Level</b></td><td><b>Problem of the 1st Level</b></td><td><b>ID 2nd Level</b></td><td><b>Problem of the 2nd Level</b></td><td><b>Count problems</b></td></tr>\n";		
	print $res "<tr><td rowspan=9 align=\"center\">1</td><td rowspan=9>MD5 isn't present on the server, but has to be</td><td align=\"center\">1_1</td><td>There is no message on this MD5 in the table audit.search</td><td align=\"center\">".${"mas_1_1_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_2</td><td>There are no messages on the publication in the table audit.search</td><td align=\"center\">".${"mas_1_2_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_3</td><td>The message on the publication is, but it isn't present in TaskLog</td><td align=\"center\">".${"mas_1_3_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_4</td><td>The message on the publication is, is in TaskLog, but isn't sent in Rabbit</td><td align=\"center\">".${"mas_1_4_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_5</td><td>The message on the publication is, is in TaskLog, is sent in Rabbit, but the server didn't reach</td><td align=\"center\">".${"mas_1_5_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_6</td><td>The message on the publication is, is in TaskLog, is sent in Rabbit, there is a confirmation, but on the server isn't present</td><td align=\"center\">".${"mas_1_6_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_7</td><td>The message on the publication is, but afterwards the message on a recall</td><td align=\"center\">".${"mas_1_7_count"}."</tr></td>\n";	
	print $res "<tr><td align=\"center\">1_8</td><td>The message on the initialize is, is in TaskLog, is sent in Rabbit, there is a confirmation, but on the server isn't present</td><td align=\"center\">".${"mas_1_8_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">1_9</td><td>The message on the publication is, verdicts in WL and Audit are different</td><td align=\"center\">".${"mas_1_9_count"}."</td></tr>\n";			
	print $res "<tr><td rowspan=9 align=\"center\">2</td><td rowspan=9>MD5 is on the server, but shouldn't be</td><td align=\"center\">2_1</td><td>There is no message on this MD5 in the table audit.search</td><td align=\"center\">".${"mas_2_1_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_2</td><td>There are no messages on the recall in the table audit.search</td><td align=\"center\">".${"mas_2_2_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_3</td><td>The message on the recall is, but it isn't present in TaskLog</td><td align=\"center\">".${"mas_2_3_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_4</td><td>The message on the recall is, is in TaskLog, but isn't sent in Rabbit</td><td align=\"center\">".${"mas_2_4_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_5</td><td>The message on the recall is, is in TaskLog, is sent in Rabbit, but the server didn't reach</td><td align=\"center\">".${"mas_2_5_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_6</td><td>The message on the recall is, is in TaskLog, is sent in Rabbit, there is a confirmation, but on the server isn't present</td><td align=\"center\">".${"mas_2_6_count"}."</td></tr>\n";		
	print $res "<tr><td align=\"center\">2_7</td><td>The message on the recall is, but afterwards the message on a publication</td><td align=\"center\">".${"mas_2_7_count"}."</tr></td>\n";		
	print $res "<tr><td align=\"center\">2_8</td><td>The message on the initialize is, is in TaskLog, is sent in Rabbit, there is a confirmation, but on the server isn't present</td><td align=\"center\">".${"mas_2_8_count"}."</td></tr>\n";			
	print $res "<tr><td align=\"center\">2_9</td><td>The message on the recall is, verdicts in WL and Audit are different</td><td align=\"center\">".${"mas_2_9_count"}."</td></tr>\n";				
	print $res "<tr><td colspan=4>Not found fails</td><td align=\"center\">".$count_analyze_fail_notfound."</td></tr>\n";			
	print $res "<tr><td colspan=4>Not found exist</td><td align=\"center\">".$count_analyze_exist_notfound."</td></tr>\n";			
	print $res "</table>\n";			
}

sub zabbix_send
{
	my $server=shift;
	my $element=shift;
	my $server_name=shift;	
	my $digit=shift;
	
	my $shell="/usr/local/bin/zabbix_sender -z $server -p 10051 -k \"$element\" -s \"$server_name\" -o $digit";
	my @result_zabbix=`$shell`; 
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