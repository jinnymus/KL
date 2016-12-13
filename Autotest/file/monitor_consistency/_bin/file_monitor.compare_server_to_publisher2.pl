#!/usr/bin/perl

use Time::localtime;
#use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;

print_time("start script");

$path=seach_params2('/file/parameters.dat','path');
$packet_size=seach_params2('/file/parameters.dat','packet_file_size');
$test_type=shift;
$test_folder=shift;
$test_testname_basic="file";
$zabbix_server=seach_params2('/file/parameters.dat','zabbix_server');

print_time("start rm logs");
print_time("path = ".$path);
print_time("try delete");

#opendir (DIR, $path.'/logs/') or die $!; 
#my @files = grep /\.log$/, readdir(DIR); 
#closedir DIR; 

#foreach my $file (@files) 
#{ 
#	unlink ($path.'/logs/'.$file) or die $!; 
#} 

print_time("delete completed");
#system("rm -rf ".$path."/logs/*");
print_time("start get hours");

$tm_start = localtime;
$hour=$tm_start->hour;
if ($hour < 10)
{
	$hour_str="0".$hour;
}
else
{
	$hour_str=$hour;
}
print "hour = ".$hour."\n";
print "hour_str = ".$hour_str."\n";
if ($test_type eq "agregate")
{
	$folder_packets=$test_folder;	
}
else
{
	$folder_packets=$path."/packet_files/packets_".$hour_str."_";
}
print "folder_packets = ".$folder_packets."\n";
opendir(DIR, $folder_packets);
#opendir(DIR, "/export/test");
@FILES= readdir(DIR); 
print "count FILES = ".scalar(@FILES)."\n";
my $count_test_files=scalar(@FILES);

if ($count_test_files == 0)
{
	unlink ("/file/file_sql_debug.html");
	open(file_sql_debug,"> /file/file_sql_debug.html");
	open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail__.log");
	
	for (my $i=0;$i<100;$i++)
	{
		print log_server_sqlfail "MD5 request fail = count_test_files\n";	
		print log_server_sqlfail "SQL Fail count_test_files = ".$count_test_files."<br>\n";
		print log_server_sqlfail "script = count_test_files compare_server_to_publisher<br>\n";
	}
	
	print file_sql_debug "SQL Fail count_test_files = ".$count_test_files."<br>\n";
	print file_sql_debug "script = count_test_files compare_server_to_publisher<br>\n";
	
	my $mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
	print "mail_email_addreses = ".$mail_email_addreses."\n";
	my $subject="File. Monitoring test - Consistency. Debug info - SQL Fail";
	my $type="html";
	system("/file/_bin/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
	close(file_sql_debug);
	close(log_server_sqlfail);
	unlink ("/file/file_sql_debug.html");	
	
	exit;
}
@files_md5s=grep(/_md5s_/,@FILES);
print "count files_md5s = ".scalar(@files_md5s)."\n";
@files_verdicts=grep(/_verdicts_/,@FILES);
print "count files_verdicts = ".scalar(@files_verdicts)."\n";
#@logfiles = sort @logfiles_unsort;
$tm_start = localtime;
$datetime_start=($tm_start->year+1900).'-'.(($tm_start->mon)+1).'-'.$tm_start->mday.'_'.$tm_start->hour.':'.$tm_start->min.':'.$tm_start->sec;
print_time("start test");
get_mas_from_folders();
testing($path,$folder_packets,$packet_size);
$tm_end = localtime;
$datetime_end=($tm_end->year+1900).'-'.(($tm_end->mon)+1).'-'.$tm_end->mday.'_'.$tm_end->hour.':'.$tm_end->min.':'.$tm_end->sec;
print_time( "end test");

#system("rm -rf ".$folder_packets);

sub get_mas_from_folders
{

	my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	#my $user = q/KL\\kalistratov/;
	#my $pass = q/Y6UHYziF/;
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;
	
	my $dbh_check = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
	{
			PrintError  => 0,
			PrintWarn  => 0,
			HandleError => sub 
			{
				my $message=$DBI::errstr;
				print "execute message is ".$message."'\n";
				print "execute the server is '$server'\n";

			 
				unlink ("/file/file_sql_debug.html");
				open(file_sql_debug,"> /file/file_sql_debug.html");
				open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_.log");
				print log_server_sqlfail "MD5 request fail = handle error\n";	
				print file_sql_debug "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "server = ".$server."<br>\n";
				print log_server_sqlfail "server = ".$server."<br>\n";
				print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "script = get_mas_from_folders compare_server_to_publisher<br>\n";
				print log_server_sqlfail "script = get_mas_from_folders compare_server_to_publisher<br>\n";
				$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
				print "mail_email_addreses = ".$mail_email_addreses."\n";
				$subject="File. Monitoring test - Consistency. Debug info - SQL Fail";
				$type="html";
				system("/file/_bin/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
				close(file_sql_debug);
				close(log_server_sqlfail);
				unlink ("/file/file_sql_debug.html");	
				
				exit; 	
			}
		}
	);
		
	$dbh_check->syb_date_fmt('ISO');	

	#my $i=0;
	foreach my $file (@files_md5s)
	{

		print "get md5s_file = ".$file."\n";
		#print $debuglog "testing server ".$server." md5s_file = ".$file."\n";
		chomp $file;
		print_time( "get_mas_from_folder create_thread process file ".$file);
		my $file_id=cut($file,"3","_");
		print_time("start request");
		#print $debuglog "start request md5s_file = ".$file."\n";
		#@verdicts_mas=request($path,$folder_packets."/".$file,$server,*debuglog,$error_refused_retry);
		open(file_request,$folder_packets."/".$file);
		my @file_request=<file_request>;
		my @file_request_mas=sort @file_request;
		my @file_request_mas_unique=();
		#print "i = ".$index."\n";
		foreach my $item (@file_request_mas)
		{
			chomp $item;
			if (!grep(/$item/,@file_request_mas_unique))
			{
				#print "push file_request_mas_unique item = ".$item."\n";
				push (@file_request_mas_unique, $item);
			}
			else
			{
				print "exist ".$item."\n";
			}
		}
		#$thread[$i] = threads->new(\&check_md5, $file, *file_request_mas);
		#$i++;		
		$file_request_mas_unique_d = \@file_request_mas_unique;
		@{"res_publisher_mas_".$file_id}=check_md5($dbh_check,$file,$file_request_mas_unique_d);
		#print $res_publisher_mas[0];
		print "[get_mas_from_folders] count res_publisher_mas_ = ".scalar(@{"res_publisher_mas_".$file_id})."\n";
		print "[get_mas_from_folders] count res_publisher_mas_ = ".scalar(@file_request_mas_unique)."\n";

	}
	$dbh_check->disconnect;
	
	#my $i=0;
	#foreach my $file (@files_md5s)
	#{
	#	chomp $file;
	#	print_time( "get_mas_from_folder get_thread process file ".$file);
	#	$file_id=cut($file,"3","_");
	#	my $result=$thread[$i]->join;
	#	@{"res_publisher_mas_".$file_id}=@$res;
	#	$i++;		
	#}
}

sub testing
{
	$path=shift;
	$folder_packets=shift;
	$packet_size=shift;
	open(servers,$path."/file_servers.dat");
	my @servers = <servers>;
	print "start testing\n";
	@servers_sort=sort(@servers);
	@pids;
	my $i_pids=0;
	foreach my $server (@servers_sort)
	{ 
		#$server="62.128.100.92";
		chomp $server;
		print "testing server ".$server."\n";
		my $pid=fork();
		if ($pid==0)
		{
			my $result = `/usr/local/sbin/fping '$server' | cut -f 3 -d ' '`;
			chomp $result;		
			print "File server ".$server." ".$result."\n";		
			if ($result eq "alive")
			{	
				my $shell_nc="/file/_bin/controller.nc.pl ".$server." ".$path."/logs/".$test_testname_basic."_debuglog_.log";
				my $result_nc = `$shell_nc`;							
				print_time("shell_nc = ".$shell_nc);
				chomp $result_nc;				
				if ($result_nc eq "succeeded!")
				{		
					zabbix_send($zabbix_server,"file.consistency.servicedown",cut($server_name,"0","."),0);
					zabbix_send($zabbix_server,"file.consistency.unreachable",cut($server_name,"0","."),0);				
					test_server($path,$server,$folder_packets,$packet_size);
					exit;
				}
				else
				{
					zabbix_send($zabbix_server,"file.consistency.servicedown",cut($mas[$indx_mas_html][1],"0","."),1000);
					zabbix_send($zabbix_server,"file.consistency.unreachable",cut($mas[$indx_mas_html][1],"0","."),0);				
					print "Error text = file_server ".$server." is servicedown. Result = ".$result_nc;
					open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
					print errorlog "Error text = file_server is servicedown. Result = ".$result_nc."\n";
					close(errorlog);			
				}						
			}
			else
			{
				zabbix_send($zabbix_server,"file.consistency.servicedown",cut($mas[$indx_mas_html][1],"0","."),0);
				zabbix_send($zabbix_server,"file.consistency.unreachable",cut($mas[$indx_mas_html][1],"0","."),1000);
				print "Error text = file_server ".$server." is unreachable. Result = ".$result;
				open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
				print errorlog "Error text = file_server is unreachable. Result = ".$result."\n";
				close(errorlog);			
			}
			exit;
		}
		else
		{
			print "Starting fork at pid=".$pid." server = ".$server."\n";
			$pids[$i_pids]=$pid;
			$i_pids++;
		}	
	}
	close(servers);
	print "all threads created\n";

	foreach (@pids)
	{
		waitpid ($_,0);
	}
	print "end testing\n";
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

sub check_md5
{
	use DBI;
	use DBD::Sybase;
	use v5.10;
    
	my $dbh=shift;
	my $file=shift;
	my $verdicts_mas=shift;	
	
	#my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	##my $user = q/KL\\kalistratov/;
	##my $pass = q/Y6UHYziF/;
	#my $user = q/tester/;
	#my $pass = q/Test#$%Test/;
	
	#my $dbh = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
	#	{
	#		PrintError  => 0,
	#		HandleError => \&handle_error,
	#	}
	#	) or handle_error($DBI->errstr);
	#$dbh->syb_date_fmt('ISO');		
	
	BEGIN 
	{ 
		$ENV{SYBASE} = "/usr/local"; 
	}

	#my $path=shift;
	#my $dbh=shift;

	@mas_result_sql=();
	#my $mas_result_sql;
	my $table_name="#table".$$;
	#$indx_mas_result=0;
	#$indx_verdicts_mas=0;
	$sql_insert="";
	foreach my $md5 (@$verdicts_mas)
	{
		chomp $md5;
		#print "[check_md5] insert md5 ".$md5."\n";
		$sql_insert=$sql_insert."insert \@md5table( md5 ) values( 0x".cut($md5,"0",";")." );\n";
		#$indx_verdicts_mas++;
	}
	
	print_time("check md5 to mas file ".$file);	
	my $sql="declare \@md5table as MD5Table ".$sql_insert." CREATE TABLE $table_name (md5 binary(16), sha3 binary(20), TimeAdded datetime, LastZonechangeTime datetime, verdict nvarchar(32),isuploaded nvarchar(32),vendor nvarchar(300),product nvarchar(300),category binary(16));
								insert $table_name exec testing.File_Get_ByMd5 \@md5table = \@md5table;
								select * from $table_name order by md5;
								drop table $table_name;";
	
	#my $sql="declare \@md5table as MD5Table ".$sql_insert."
	#		exec testing.File_Get_ByMd5 \@md5table = \@md5table;";
	
	my $sth = $dbh->prepare($sql);
	$sth -> execute();
	#@rows = $sth->fetchrow_array();
	my @rows;

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
		my $verdict=lc($rows[4]);
		my $isuploaded=$rows[5];	

		if ($timeadded_publisher eq "")
		{
			$timeadded_publisher="null null";
		}
		if ($lastchangetimezone_publisher eq "")
		{
			$lastchangetimezone_publisher="null null";
		}		
		if ($verdict eq "")
		{
			$verdict="null";
		}	
		if ($isuploaded eq "")
		{
			$isuploaded="NULL";
		}	
		push (@mas_result_sql,$md5.";".$sha.";".$timeadded_publisher.";".$lastchangetimezone_publisher.";".$verdict.";".$isuploaded.";");
		#push (@$mas_result_sql,$md5.";".$sha.";".$timeadded_publisher.";".$lastchangetimezone_publisher.";".lc($rows[4]).";".$rows[5].";");
	}

	$count_mas_result_sql=scalar(@mas_result_sql);
	#$count_mas_result_sql=scalar(@$mas_result_sql);
	print_time("mas_result_sql = ".$count_mas_result_sql." file ".$file);
	$rc = $sth -> finish;

	return @mas_result_sql;
	#return $mas_result_sql;
}

sub print_time
{
	$text=shift;
	$tm_now = localtime;
	$datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
}
sub handle_error 
{
	my $message=shift;
	my $message_error_code=shift;
	my $message_error_text=shift;
	my $server=shift;
	
	print "connect the message_error_code is ".$message_error_code."'\n";
	print "connect the message_error_text is ".$message_error_text."'\n";
	print "connect the message is ".$message."'\n";
	print "connect the server is '$server'\n";

	unlink ("/file/file_sql_debug.html");
	open(file_sql_debug,"> /file/file_sql_debug.html");
	open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_".$server.".log");
	print log_server_sqlfail "MD5 request fail = handle error\n";	
	print file_sql_debug "SQL Fail message = ".$message."<br>\n";
	print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
	print log_server_sqlfail "message_error_code = ".$message_error_code."<br>\n";
	print log_server_sqlfail "message_error_text = ".$message_error_text."<br>\n";	
	print file_sql_debug "message_error_code = ".$message_error_code."<br>\n";
	print file_sql_debug "message_error_text = ".$message_error_text."<br>\n";	
	print file_sql_debug "server = ".$server."<br>\n";	
	print file_sql_debug "script = handle_error compare_server_to_publisher<br>\n";
	print log_server_sqlfail "script = handle_error compare_server_to_publisher<br>\n";
	$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
	print "mail_email_addreses = ".$mail_email_addreses."\n";
	$subject="File. Monitoring test - Consistency. Debug info - SQL Fail";
	$type="html";
	
	system("/file/_bin/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
	close(file_sql_debug);
	close(log_server_sqlfail);
	unlink ("/file/file_sql_debug.html");	
	
    exit; #stop the program
}
sub test_server
{
	my $path=shift;
	my $server=shift;
	my $folder_packets=shift;
	my $packet_size=shift;
	
	chomp $server;
	print "testing server ".$server."\n";
	$indx_files=1;
	
	$error_refused_retry=seach_params2('/file/parameters.dat','error_refused_retry');
	
	my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	#my $user = q/KL\\kalistratov/;
	#my $pass = q/Y6UHYziF/;
	my $user = q/tester/;
	my $pass = q/Test#$%Test/;
	
	my $dbh = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
	{
			PrintError  => 0,
			PrintWarn  => 0,
			HandleError => sub 
			{
				my $message=$DBI::errstr;
				print "execute message is ".$message."'\n";
				print "execute the server is '$server'\n";

			 
				unlink ("/file/file_sql_debug.html");
				open(file_sql_debug,"> /file/file_sql_debug.html");
				open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_".$server.".log");
				print log_server_sqlfail "MD5 request fail = handle error\n";	
				print file_sql_debug "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "server = ".$server."<br>\n";
				print log_server_sqlfail "server = ".$server."<br>\n";
				print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "script = test_server compare_server_to_publisher<br>\n";
				print log_server_sqlfail "script = test_server compare_server_to_publisher<br>\n";
				$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
				print "mail_email_addreses = ".$mail_email_addreses."\n";
				$subject="File. Monitoring test - Consistency. Debug info - SQL Fail";
				$type="html";
				system("/file/_bin/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
				close(file_sql_debug);
				close(log_server_sqlfail);
				unlink ("/file/file_sql_debug.html");	
				
				exit; 	
			}
		}
	);
		
	
	$dbh->syb_date_fmt('ISO');		
	
	open($debuglog,">> ".$path."/logs/file_debuglog_".$server.".log");
	
	foreach $file (@files_md5s)
	{
		print "testing server ".$server." md5s_file = ".$file."\n";
		print $debuglog "testing server ".$server." md5s_file = ".$file."\n";
		chomp $file;
		$file_id=cut($file,"3","_");
		print_time("start request");
		print $debuglog "start request md5s_file = ".$file."\n";
		@verdicts_mas=request($path,$folder_packets."/".$file,$server,*debuglog,$error_refused_retry);
		print_time("end request");
		print $debuglog "end request md5s_file = ".$file."\n";
		if ($verdicts_mas[0] ne "-1")
		{
			if (scalar(@verdicts_mas) == $packet_size)
			{
				$count_mas=scalar(@verdicts_mas);
				#print "count_mas = ".$count_mas."\n";
				#@result=compare_with_file($path,$path."/packet_files/packet_file_verdicts_".$file_id."_.dat",*verdicts_mas);
				print_time("start compare_with_publisher");
				@result=compare_with_publisher($path,$folder_packets."/packet_file_verdicts_".$file_id."_.dat", $file_id, $dbh,*verdicts_mas);
				$count_result=scalar(@result);
				#if ($result[0][0] ne "-1")
				#{
					#print "count_result = ".$count_result."\n";
					print_time("count_result = ".$count_result);
					#print_time("result[0][0] = ".$result[0][0]);
					print_time("end compare_with_publisher");
					$indx_res=0;
					print_time("start print result");
					open(log_server,">> ".$path."/logs/file_".$server.".log");
					open(log_server_fail,">> ".$path."/logs/file_fail_".$server.".log");			
					foreach(@result)
					{
						#print_time("result[0][0] = ".$result[0][0]);
						print log_server "md5 = ".$result[$indx_res][0]." md5_source = ".$result[$indx_res][8]." sha_source = ".$result[$indx_res][9]." sha_publisher = ".$result[$indx_res][7]." md5_publisher = ".$result[$indx_res][6]." verdict_publisher = ".$result[$indx_res][1]." verdict_server = ".$result[$indx_res][2]." timeadded_publisher = ".$result[$indx_res][3]." lastchangetimezone_publisher = ".$result[$indx_res][4]." isuploaded ".$result[$indx_res][5]." - Fail\n";
						print log_server_fail "md5 = ".$result[$indx_res][0]." md5_source = ".$result[$indx_res][8]." sha_source = ".$result[$indx_res][9]." sha_publisher = ".$result[$indx_res][7]." md5_publisher = ".$result[$indx_res][6]." verdict_publisher = ".$result[$indx_res][1]." verdict_server = ".$result[$indx_res][2]." timeadded_publisher = ".$result[$indx_res][3]." lastchangetimezone_publisher = ".$result[$indx_res][4]." isuploaded ".$result[$indx_res][5]." - Fail\n";
						$indx_res++;
					}
					close(log_server);
					close(log_server_fail);
					print_time("end print result");
					print_time("indx_files = ".$indx_files);
				#}
				#else
				#{
				#	print_time("sqlfail test_server");
				#	open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_".$server.".log");
				#	print log_server_sqlfail "sqlfail test_server\n";
				#	close(log_server_sqlfail);						
				#}
			}
			else
			{
				print_time("no 5000");
				open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
				print errorlog "===========\n";
				print errorlog "MD5 = ".$file."\n";
				print errorlog "MD5 count response = ".scalar(@verdicts_mas)."\n";
				print errorlog "===========\n";
				close(errorlog);			
			}
		}
		$indx_files++;		
	}
	
	close($debuglog);	
	
	$dbh->disconnect;	
}

sub compare_with_publisher
{
	$path=shift;
	$file_verdicts_source=shift;
	$file_id=shift;
	$dbh=shift;
	*verdicts_mas=shift;
	
	$indx_source=0;
	$indx_mas=0;
	$indx_result=0;
	@mas_result=();
	
	open(file_verd_source,$file_verdicts_source);
	@file_verd_source_unsort=<file_verd_source>;
	@file_verd_source = sort @file_verd_source_unsort;
	my @res_publisher_mas;
	print_time("start check_md5");
	#@res_publisher_mas=check_md5($path,$dbh,*verdicts_mas);
	print_time("file_id = ".$file_id);
	@res_publisher_mas=@{"res_publisher_mas_".$file_id};
	print_time("count res_publisher_mas file id = ".scalar(@{"res_publisher_mas_".$file_id}));
	print_time("count res_publisher_mas = ".scalar(@res_publisher_mas));
	print_time("count file_id = ".$file_id);
	print_time("end check_md5");
	print_time("count verdicts_mas = ".scalar(@verdicts_mas));
	$count_res_publisher_mas=scalar(@res_publisher_mas);
	
	print_time("count_res_publisher_mas = ".$count_res_publisher_mas);
	print_time("packet_size = ".$packet_size);
	
	#if ($packet_size == $count_res_publisher_mas)
	#{
		open(log_server_ok,">> ".$path."/logs/file_ok_".$server.".log");
		open(log_server_mustnot,">> ".$path."/logs/file_mustnot_".$server.".log");
		open(log_server_mustnot_but_exist,">> ".$path."/logs/file_mustnotbutexist_".$server.".log");
		open(log_server,">> ".$path."/logs/file_".$server.".log");
		open(log_debugerror,">> ".$path."/logs/file_debugerror_".$server.".log");
		open(log_md5dublicate,">> ".$path."/logs/file_md5dublicate_".$server.".log");
		open(log_filedublicate,">> ".$path."/logs/file_filedublicate_".$server.".log");
		open(log_notdublicate,">> ".$path."/logs/file_notdublicate_".$server.".log");
		open(log_verdictdublicate,">> ".$path."/logs/file_verdictdublicate_".$server.".log");		
		
		foreach my $line (@verdicts_mas)
		{
			chomp $line;
			my $md5_mas=cut($line,"0",";");
			my $verdict_mas=cut($line,"1",";");
			#$md5_mas=$verdicts_mas[$indx_mas][0];
			#print_time("start check_md5");
			#$res_publisher=check_md5($path,$md5_mas);
			
			#my $res_publisher=$res_publisher_mas[$indx_mas];
			@res_publisher_mas_one=grep(/$md5_mas/,@res_publisher_mas);			
			my $res_publisher_mas_one_count = scalar(@res_publisher_mas_one);
			#print "[compare_with_publisher] res_publisher_mas_one_count = ".$res_publisher_mas_one_count."\n";
			
			@md5_data_source_mas=grep(/$md5_mas/,@file_verd_source);
			$md5_data_source=$md5_data_source_mas[0];
			chomp $md5_data_source;
			#$md5_data_source=$file_verd_source[$indx_mas];
			#print "[compare_with_publisher] md5_data_source = ".$md5_data_source."\n";								
			
			$md5_source=cut($md5_data_source,"0",";");
			$sha_source=cut($md5_data_source,"1",";");
			$sha256_source=cut($md5_data_source,"3",";");			
			
			#print "[compare_with_publisher] res_publisher_mas_one res_publisher = ".$res_publisher_mas_one[0]."\n";
			#print "[compare_with_publisher] res_publisher_mas_one count_res_publisher_mas = ".$count_res_publisher_mas."\n";
			#print "[compare_with_publisher] res_publisher_mas_one md5_mas = ".$md5_mas."\n";
			
			if ($res_publisher_mas_one_count > 1)
			{
				print "[compare_with_publisher][MD5 dublicate] MD5 dublicate found\n";
				my @shas=();
				my @verdicts=();
				my $verdicts_good=0;
				my $verdicts_bad=0;
				my $verdicts_null=0;
				foreach my $line (@res_publisher_mas_one)
				{
					print "[compare_with_publisher][MD5 dublicate] line = ".$line."\n";	
					$md5_publisher=cut($line,"0",";");
					$sha_publisher=cut($line,"1",";");
					$isuploded=cut($line,"5",";");
					$verdict_publisher=cut($line,"4",";");
					$timeadded_publisher=cut($line,"2",";");
					$lastchangetimezone_publisher=cut($line,"3",";");	
					if (!grep(/$sha_publisher/, @shas))
					{
						print "[compare_with_publisher][MD5 dublicate] push sha_publisher = ".$sha_publisher."\n";
						push @shas, $sha_publisher;
					}
					if (!grep(/$verdict_publisher/, @verdicts))
					{
						print "[compare_with_publisher][MD5 dublicate] push verdict_publisher = ".$verdict_publisher."\n";					
						push @verdicts, $verdict_publisher;
					}					
					if ($verdict_publisher eq "good")
					{
						$verdicts_good++;
					}
					elsif ($verdict_publisher eq "bad")
					{
						$verdicts_bad++;
					}
					elsif ($verdict_publisher eq "null")
					{
						$verdicts_null++;
					}					
					if ($verdict_publisher eq "")
					{
						print log_debugerror "res_publisher verdict_publisher is null  res_publisher = ".$res_publisher." count_res_publisher_mas = ".$count_res_publisher_mas."\n";
					}						
					print log_md5dublicate "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - ?\n";								
				}
				my $shas_count=scalar(@shas);
				my $verdicts_count=scalar(@verdicts);
				print "[compare_with_publisher][MD5 dublicate] res_publisher_mas_one_count = ".$res_publisher_mas_one_count."\n";	
				print "[compare_with_publisher][MD5 dublicate] shas_count = ".$shas_count."\n";	
				print "[compare_with_publisher][MD5 dublicate] verdicts_count = ".$verdicts_count."\n";	
				print "[compare_with_publisher][MD5 dublicate] verdicts_good = ".$verdicts_good."\n";	
				print "[compare_with_publisher][MD5 dublicate] verdicts_bad = ".$verdicts_bad."\n";	
				print "[compare_with_publisher][MD5 dublicate] verdicts_null = ".$verdicts_null."\n";	
				if ($res_publisher_mas_one_count == $shas_count)
				{
					if ($verdicts_bad != 0 && $verdicts_good != 0)
					{
						print "[compare_with_publisher][MD5 dublicate] file ok - verdict question\n";	
						print log_verdictdublicate "md5_mas = ".$md5_mas." shas_count = ".$shas_count." res_publisher_mas_one_count = ".$res_publisher_mas_one_count." verdicts_bad = ".$verdicts_bad." verdicts_good = ".$verdicts_good." verdicts_null = ".$verdicts_null."\n";														
					}
					else
					{
						print log_notdublicate "md5_mas = ".$md5_mas." shas_count = ".$shas_count." res_publisher_mas_one_count = ".$res_publisher_mas_one_count." verdicts_bad = ".$verdicts_bad." verdicts_good = ".$verdicts_good." verdicts_null = ".$verdicts_null."\n";
					}
					print "[compare_with_publisher][MD5 dublicate] file ok\n";
				}				
				elsif ($res_publisher_mas_one_count != $shas_count)
				{
					#elsif ($res_publisher_mas_one_count != $shas_count && !grep(/NULL/, @shas))
					print "[compare_with_publisher][MD5 dublicate] file dublicate\n";
					print log_filedublicate "md5_mas = ".$md5_mas." shas_count = ".$shas_count." res_publisher_mas_one_count = ".$res_publisher_mas_one_count." verdicts_bad = ".$verdicts_bad." verdicts_good = ".$verdicts_good." verdicts_null = ".$verdicts_null."\n";
				}
				else
				{
					print "[compare_with_publisher][MD5 dublicate] file not dublicate\n";
				}
			}
			else
			{
				my $res_publisher=$res_publisher_mas_one[0];
				#print "[compare_with_publisher] res_publisher_mas_one res_publisher = ".$res_publisher_mas_one[0]."\n";
				
				$md5_publisher=cut($res_publisher,"0",";");
				$sha_publisher=cut($res_publisher,"1",";");
				$isuploded=cut($res_publisher,"5",";");
				$verdict_publisher=cut($res_publisher,"4",";");
				$timeadded_publisher=cut($res_publisher,"2",";");
				$lastchangetimezone_publisher=cut($res_publisher,"3",";");				
				
				if ($verdict_publisher eq "")
				{
					print log_debugerror "res_publisher verdict_publisher is null  res_publisher = ".$res_publisher." count_res_publisher_mas = ".$count_res_publisher_mas."\n";
				}				
				#print "[compare_with_publisher] res_publisher = ".$res_publisher."\n";	
				#print_time("res_publisher_data_mas start md5_mas = ".$md5_mas);
				#@res_publisher_data_mas=grep(/$md5_mas/,@res_publisher_mas);
				#print_time("res_publisher_data_mas end md5_mas = ".$md5_mas);
				#$res_publisher=$res_publisher_data_mas[0];
				
				#$res_publisher=$res_publisher_mas[$indx_mas];
				#print_time("res_publisher = ".$res_publisher);
				#print_time("end check_md5");
				
				#print_time("md5_data_source_mas start md5_mas = ".$md5_mas);
				#@md5_data_source_mas=grep(/$md5_mas/,@file_verd_source);
				#print_time("md5_data_source_mas end md5_mas = ".$md5_mas);
				
				#$md5_data_source=$md5_data_source_mas[0];

				#print "md5_source = ".$md5_source."\n";
				#print "id = ".cut($file_verd_source[$indx_source],"0",";")."\n";
				if (($sha_publisher eq $sha_source) || ($sha_source eq "NULL"))
				{
					if($verdict_mas ne $verdict_publisher)
					{
						if ($isuploded == 1)
						{
							#print_time("md5_mas = ".$md5_mas);
							#print_time("verdict_publisher = ".$verdict_publisher);
							#print_time("verdict_mas = ".$verdict_mas);
							#print_time("timeadded_publisher = ".$timeadded_publisher);
							#print_time("lastchangetimezone_publisher = ".$lastchangetimezone_publisher);
							#print_time("isuploded = ".$isuploded);
							#print_time("md5_publisher = ".$md5_publisher);
							$mas_result[$indx_result][0]=$md5_mas;
							$mas_result[$indx_result][1]=$verdict_publisher;
							$mas_result[$indx_result][2]=$verdict_mas;
							$mas_result[$indx_result][3]=$timeadded_publisher;
							$mas_result[$indx_result][4]=$lastchangetimezone_publisher;
							$mas_result[$indx_result][5]=$isuploded;
							$mas_result[$indx_result][6]=$md5_publisher;
							$mas_result[$indx_result][7]=$sha_publisher;
							$mas_result[$indx_result][8]=$md5_source;
							$mas_result[$indx_result][9]=$sha_source;
							#print_time("mas_result[$indx_result][0] = ".$mas_result[$indx_result][0]);
							#print_time("mas_result[$indx_result][1] = ".$mas_result[$indx_result][1]);
							#print_time("mas_result[$indx_result][2] = ".$mas_result[$indx_result][2]);
							#print_time("mas_result[$indx_result][3] = ".$mas_result[$indx_result][3]);
							#print_time("mas_result[$indx_result][4] = ".$mas_result[$indx_result][4]);
							#print_time("mas_result[$indx_result][5] = ".$mas_result[$indx_result][5]);
							#print_time("mas_result[$indx_result][6] = ".$mas_result[$indx_result][6]);					
							#print_time("mas_result[$indx_result][7] = ".$mas_result[$indx_result][7]);					
							$indx_result++;
						}
						else
						{
							print log_server_mustnot "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - ?\n";			
						}
					}
					else
					{
						if ($isuploded == 1)
						{
							print log_server_ok "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - OK\n";
							print log_server "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - OK\n";			
						}
						else
						{
							print log_server_mustnot_but_exist "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - ?\n";			
						}
					}
				}
				else
				{
					open(log_server_shanoeq,">> ".$path."/logs/file_shanoeq_".$server.".log");
					print log_server_shanoeq "md5_mas = ".$md5_mas." md5_publisher = ".$md5_publisher." md5_source = ".$md5_source." sha_source = ".$sha_source." sha_publisher_mas = ".$sha_publisher." verdict_publisher = ".$verdict_publisher." verdicts_mas = ".$verdict_mas." timeadded_publisher = ".$timeadded_publisher." lastchangetimezone_publisher = ".$lastchangetimezone_publisher." isuploaded ".$isuploded." - ?\n";							
					close(log_server_shanoeq);
				}
			}
			#$indx_mas++;
		}
		close(log_server);
		close(log_debugerror);
		close(log_server_ok);			
		close(log_server_mustnot);		
		close(log_server_mustnot_but_exist);	
		close(log_md5dublicate);	
		close(log_filedublicate);	
		close(log_notdublicate);			
		close(log_verdictdublicate);	
		
		#print_time("count mas_result (if) = ".scalar(@mas_result));
	#}	
	# else
	# {
		#print_time("count mas_result (else) = ".scalar(@mas_result));
		# print_time("sqlfail compare_with_publisher");
		# open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_.log");
		# print log_server_sqlfail "MD5 request fail = ".$count_res_publisher_mas."\n";
		# print log_server_sqlfail "sqlfail compare_with_publisher\n";		
		# print log_server_sqlfail "=================\n";
		# $md5_found_dublicate="";
		# foreach(@res_publisher_mas)
		# {
			#print $_."\n";
			# print log_server_sqlfail $_."\n";
			# $md5=cut($_,"0",";");
			# @res_mas_count=grep(/$md5/,@res_publisher_mas);
			# $res_mas_count_count=scalar(@res_mas_count);
			# if ($res_mas_count_count > 1)
			# {
				# $md5_found_dublicate=$md5;
			# }			
		# }
		# print log_server_sqlfail "=================\n";
		# print log_server_sqlfail "md5_found_dublicate = ".$md5_found_dublicate."<br>\n";
		# print log_server_sqlfail "=================\n";
		# close(log_server_sqlfail);
		# @mas_result=();
		#$mas_result[0][0]="-1";
	# }
	return @mas_result;
}

sub compare_with_file
{
	$path=shift;
	$file_verdicts_source=shift;
	print "file_verdicts_source = ".$file_verdicts_source."\n";
	*verdicts_mas=shift;
	
	open(file_verd_source,$file_verdicts_source);
	@file_verd_source=<file_verd_source>;
	
	$indx_source=0;
	$indx_mas=0;
	$indx_result=0;
	@mas_result=();
	
	open(log_server,">> ".$path."/logs/file_ok_".$server.".log");
	
	foreach (@verdicts_mas)
	{
		$md5_source=cut($file_verd_source[$indx_source],"1",";");
		#print "md5_source = ".$md5_source."\n";
		#print "id = ".cut($file_verd_source[$indx_source],"0",";")."\n";
		$verdict_source=cut($file_verd_source[$indx_source],"2",";");
		if($verdicts_mas[$indx_mas][0] eq $md5_source)
		{
			if($verdicts_mas[$indx_mas][2] ne $verdict_source)
			{
				$mas_result[$indx_result][0]=$md5_source;
				$mas_result[$indx_result][1]=$verdict_source;
				$mas_result[$indx_result][2]=$verdicts_mas[$indx_source][2];
				$indx_result++;
			}
			else
			{
				print log_server "md5_source = ".$md5_source." md5_mas = ".$verdicts_mas[$indx_mas][0]." verdict_source = ".$verdict_source." verdicts_mas = ".$verdicts_mas[$indx_mas][2]."\n";
			}
		}
		else
		{
			print "md5 not compare md5_source = ".$md5_source." md5_mas = ".$verdicts_mas[$indx_mas][0]."\n";
		}
		$indx_source++;
		$indx_mas++;
	}
	close(log_server);	
	return @mas_result;
}

sub request_shell
{
	$path=shift;
	$md5_file=shift;
	$server=shift;
	
	$SIG{ALRM} = sub { 
						open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
						print errorlog "===========\n";
						print errorlog "MD5_timeout = ".$md5_file."\n";
						print "MD5_timeout = ".$md5_file."\n";
						print errorlog "timeout detected\n";						
						foreach (@resp_shell)
						{
							print errorlog $_;
						}
						print errorlog "===========\n";
						close(errorlog);
					}; 
	eval 
	{ 
		alarm(40); 
	};	
	
	@resp_shell=();
	@resp_shell=`$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 2>&1`;
	
	return @resp_shell;
}

sub request_old
{
	$path=shift;
	$md5_file=shift;
	$server=shift;
	*debuglog=shift;
	$error_refused_retry=shift;
	
	chomp $md5_file;
	chomp $server;
	
	@resp=`$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 2>&1`;
	if (grep {/exit with 0/} @resp) 
	{
		@verdicts_tmp=grep(/verdict/,@resp);
		@id_tmp=grep(/id/,@resp);
		
		open(md5s_file,$md5_file);
		@md5s=<md5s_file>;
		$count=scalar(@md5s);
		$count_verdicts_tmp=scalar(@verdicts_tmp);
		$count_id_tmp=scalar(@id_tmp);
		
		@verdicts=();
		$indx_verdicts=0;
		
		foreach(@verdicts_tmp)
		{
			chomp $_;
			$md5=$md5s[$indx_verdicts];
			chomp $md5;
			$id=cut($id_tmp[$indx_verdicts],"5"," ");
			chomp $id;
			$verdict=cut($_,"5"," ");
			push (@verdicts,$md5.";".$verdict.";");
			$indx_verdicts++;
		}
		@verdicts_mas=sort @verdicts;
		$count_verdicts=scalar(@verdicts);
		$count_verdicts_mas=scalar(@verdicts_mas);		

		print $debuglog "MD5s_count_tmp = ".$count." count_verdicts_tmp = ".$count_verdicts_tmp." count_id_tmp = ".$count_id_tmp." count_verdicts = ".$count_verdicts." count_verdicts_mas = ".$count_verdicts_mas."\n";
	
	}
	else
	{
		$pass=0;
		for($q=0; $q<$error_refused_retry; $q++) 
		{	
			@resp=`$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 2>&1`;
			if (grep {/exit with 0/} @resp) 
			{
				@verdicts_tmp=grep(/verdict/,@resp);
				@id_tmp=grep(/id/,@resp);
				
				open(md5s_file,$md5_file);
				@md5s=<md5s_file>;
				$count=scalar(@md5s);
				$count_verdicts_tmp=scalar(@verdicts_tmp);
				$count_id_tmp=scalar(@id_tmp);

				
				@verdicts=();
				$indx_verdicts=0;
				
				foreach(@verdicts_tmp)
				{
					chomp $_;
					$md5=$md5s[$indx_verdicts];
					chomp $md5;
					$id=cut($id_tmp[$indx_verdicts],"5"," ");
					chomp $id;
					$verdict=cut($_,"5"," ");
					push (@verdicts,$md5.";".$verdict.";");
					$indx_verdicts++;
				}
				@verdicts_mas=sort @verdicts;
				$count_verdicts=scalar(@verdicts);
				$count_verdicts_mas=scalar(@verdicts_mas);		

				print $debuglog "MD5s_count_tmp = ".$count." count_verdicts_tmp = ".$count_verdicts_tmp." count_id_tmp = ".$count_id_tmp." count_verdicts = ".$count_verdicts." count_verdicts_mas = ".$count_verdicts_mas."\n";
				$pass=1;
				last;
			}
			#sleep(2);
		}
		if ($pass == 0)
		{
			open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
			print errorlog "===========\n";
			print errorlog "MD5 = ".$md5_file."\n";
			open(md5_file,$md5_file);
			@md5_mas_packet=<md5_file>;
			print errorlog "MD5 count = ".scalar(@md5_mas_packet)."\n";
			foreach (@resp)
			{
				print errorlog $_;
			}
			print errorlog "===========\n";
			close(errorlog);
			@verdicts_mas=();
			$indx_verdicts=0;
			$verdicts_mas[0]="-1";
		}
	}
	close(md5s_file);
	return @verdicts_mas;
}

sub request
{
	$path=shift;
	$md5_file=shift;
	$server=shift;
	*debuglog=shift;
	$error_refused_retry=shift;
		
	chomp $md5_file;
	chomp $server;

	open(md5s_file,$md5_file);
	@md5s=<md5s_file>;
	$count=scalar(@md5s);
			
	@resp=();
	print_time("start request_shell ".$server." ".$md5_file);
	#@resp=request_shell($path,$md5_file,$server);
	@resp=`/file/_bin/file_monitor.shell.pl "$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 -c 60 2>&1"`;
	#@resp=`$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 2>&1`;
	print_time("end request_shell ".$server." ".$md5_file);
	
	if (grep {/exit with 0/} @resp) 
	{
		@verdicts_tmp=grep(/verdict/,@resp);
		@id_tmp=grep(/id/,@resp);

		$count_verdicts_tmp=scalar(@verdicts_tmp);
		$count_id_tmp=scalar(@id_tmp);
		#print "count = ".$count."\n";
		
		@verdicts=();
		$indx_verdicts=0;
		
		foreach(@verdicts_tmp)
		{
			chomp $_;
			$md5=$md5s[$indx_verdicts];
			chomp $md5;
			$id=cut($id_tmp[$indx_verdicts],"5"," ");
			chomp $id;
			$verdict=cut($_,"5"," ");
			push (@verdicts,$md5.";".$verdict.";");
			#$verdicts[$indx_verdicts][0]=$md5;
			#print "md5 = ".$md5."\n";
			#$verdicts[$indx_verdicts][1]=$id;
			#print "id = ".$id."\n";
			#$verdicts[$indx_verdicts][2]=$verdict;
			#print "verdict = ".$verdict."\n";
			$indx_verdicts++;
		}
		@verdicts_mas=sort @verdicts;
		$count_verdicts=scalar(@verdicts);
		$count_verdicts_mas=scalar(@verdicts_mas);		
		#print "verdicts_mas = ".scalar(@verdicts_mas)."\n";

		print $debuglog "MD5s_count_tmp = ".$count." count_verdicts_tmp = ".$count_verdicts_tmp." count_id_tmp = ".$count_id_tmp." count_verdicts = ".$count_verdicts." count_verdicts_mas = ".$count_verdicts_mas."\n";
		
	}
	else
	{
		$pass=0;
		for($q=0; $q<$error_refused_retry; $q++) 
		{	
			print_time("start request_shell ".$server." ".$md5_file." refused ".$q);
			@resp=`/file/_bin/file_monitor.shell.pl "$path/_bin/hips_test -ro -v -k '$md5_file'  -i '$server' -p 443 -c 60 2>&1"`;
			print_time("end request_shell ".$server." ".$md5_file." refused ".$q);

			if (grep {/exit with 0/} @resp) 
			{
				@verdicts_tmp=grep(/verdict/,@resp);
				@id_tmp=grep(/id/,@resp);

				$count_verdicts_tmp=scalar(@verdicts_tmp);
				$count_id_tmp=scalar(@id_tmp);
				#print "count = ".$count."\n";
				
				@verdicts=();
				$indx_verdicts=0;
				
				foreach(@verdicts_tmp)
				{
					chomp $_;
					$md5=$md5s[$indx_verdicts];
					chomp $md5;
					$id=cut($id_tmp[$indx_verdicts],"5"," ");
					chomp $id;
					$verdict=cut($_,"5"," ");
					push (@verdicts,$md5.";".$verdict.";");
					#$verdicts[$indx_verdicts][0]=$md5;
					#print "md5 = ".$md5."\n";
					#$verdicts[$indx_verdicts][1]=$id;
					#print "id = ".$id."\n";
					#$verdicts[$indx_verdicts][2]=$verdict;
					#print "verdict = ".$verdict."\n";
					$indx_verdicts++;
				}
				@verdicts_mas=sort @verdicts;
				$count_verdicts=scalar(@verdicts);
				$count_verdicts_mas=scalar(@verdicts_mas);		
				#print "verdicts_mas = ".scalar(@verdicts_mas)."\n";

				print $debuglog "MD5s_count_tmp = ".$count." count_verdicts_tmp = ".$count_verdicts_tmp." count_id_tmp = ".$count_id_tmp." count_verdicts = ".$count_verdicts." count_verdicts_mas = ".$count_verdicts_mas."\n";
				$pass=1;
				last;
			}
			sleep (2);
		}
		if ($pass == 0)
		{
			open(errorlog,">> ".$path."/logs/file_errorlog_".$server.".log");
			print errorlog "===========\n";
			print errorlog "MD5 = ".$md5_file."\n";
			print errorlog "MD5 count = ".$count."\n";
			foreach (@resp)
			{
				print errorlog $_;
			}
			print errorlog "===========\n";
			close(errorlog);
			@verdicts_mas=();
			$indx_verdicts=0;
			$verdicts_mas[0]="-1";
		}		
	}
	close(md5s_file);
	return @verdicts_mas;
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
	@a=split("$delimeter", $string);
	$value=$a[$number];
return $value;
}
