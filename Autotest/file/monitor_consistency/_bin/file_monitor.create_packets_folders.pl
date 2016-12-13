#!/usr/bin/perl

use Time::localtime;
#use strict;
use v5.10;
#use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;

$tm_start = localtime;
$datetime_start=($tm_start->year+1900).'-'.(($tm_start->mon)+1).'-'.$tm_start->mday.'_'.$tm_start->hour.':'.$tm_start->min.':'.$tm_start->sec;
print "start = ".$datetime_start."\n";

$path=seach_params2('/file/parameters.dat','path');
$packet_size=seach_params2('/file/parameters.dat','packet_file_size');
$folder_size=seach_params2('/file/parameters.dat','packet_folder_size');
$folder_size_max=seach_params2('/file/parameters.dat','mssql_export_rows');
$zabbix_server=seach_params2('/file/parameters.dat','zabbix_server');

export_data($path,$packet_size,$folder_size,$folder_size_max);

$tm_end = localtime;
$datetime_end=($tm_end->year+1900).'-'.(($tm_end->mon)+1).'-'.$tm_end->mday.'_'.$tm_end->hour.':'.$tm_end->min.':'.$tm_end->sec;
print "end = ".$datetime_end."\n";

sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";

	unlink ("/file/file_sql_debug.html");
	open(file_sql_debug,"> /file/file_sql_debug.html");
	open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail__.log");	
	print file_sql_debug "SQL Fail message = ".$message."<br>\n";
	print file_sql_debug "script = create_packet_folders<br>\n";
	print log_server_sqlfail "MD5 request fail = handle error\n";	
	print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
	print log_server_sqlfail "script = create_packet_folders<br>\n";
	
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

sub zabbix_send
{
	my $server=shift;
	my $element=shift;
	my $server_name=shift;	
	my $digit=shift;
	
	my $shell="/usr/local/bin/zabbix_sender -z $server -p 10051 -k \"$element\" -s \"$server_name\" -o $digit";
	my @result_zabbix=`$shell`; 
}

sub export_data
{
	use DBI;
	use DBD::Sybase;
	use v5.10;

	BEGIN 
	{ 
		$ENV{SYBASE} = "/usr/local"; 
	}

	my $path=shift;
	my $packet_size=shift;
	my $folder_size=shift;
	my $folder_size_max=shift;
	print "folder_size = ".$folder_size."\n";
	print "path = ".$path."\n";
	print "packet_size = ".$packet_size."\n";
	my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
	#my ($host,$port,$instance,$database,$user,$pass) = ("MSSQL","1433","SQLEXPRESS","PUB","KL\\kalistratov","Y6UHYziF");
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
				open(log_server_sqlfail,">> ".$path."/logs/file_sqlfail_.log");
				print log_server_sqlfail "MD5 request fail = handle error\n";	
				print file_sql_debug "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "server = ".$server."<br>\n";
				print log_server_sqlfail "SQL Fail message = ".$message."<br>\n";
				print file_sql_debug "script = create_packet_folders<br>\n";
				print log_server_sqlfail "script = create_packet_folders<br>\n";
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
		

	my $sql="declare \@rc int exec testing.HipsMD5RndGet \@rc=".$folder_size_max.";";
	#my $sql = "CREATE TABLE #table7842(send_date datetime, message_guid nvarchar(36), md5 binary(16), verdict nvarchar(32));
	#			insert #table7842 exec dbo.get_last_hips_verdict \@rc=200000;
	#			select md5,verdict from #table7842
	#			drop table #table7842;";
	print $sql."\n";
	$dbh->syb_date_fmt('ISO');
	print "prepare\n";
	my $sth = $dbh->prepare($sql);
	print "execute\n";
	$sth -> execute();
	my @rows;
	
	$count_res=0;
	$indx_file_source=1;
	$indx_packet_file=1;
	$indx_folder_file=1;
	$indx_md5=1;
	$indx_md5_all=1;;
	$hour=0;
	$hour_str="0".$hour;
	print "mkdir\n";
	mkdir ($path."/packet_files/packets_".$hour_str."_");
	open(packet_file_md5s,">> ".$path."/packet_files/packets_".$hour_str."_/packet_file_md5s_".$indx_packet_file."_.dat");
	open(packet_file_verdicts,">> ".$path."/packet_files/packets_".$hour_str."_/packet_file_verdicts_".$indx_packet_file."_.dat");		
	
	print "fetchrow_array\n";
	while(@rows = $sth->fetchrow_array()) 
	{ 
		
		#print $rows[0].";".$rows[1].";".$rows[2].";".$rows[3].";\n";
		my $md5 = $rows[0];
		my $sha = $rows[1];
		my $sha256 = $rows[2];
		my $verdict = lc($rows[3]);

		if ($sha eq "")
		{
			$sha = "NULL";
		}
		if ($sha256 eq "")
		{
			$sha256 = "NULL";
		}		
		
		print packet_file_md5s $md5."\n";
		#print packet_file_verdicts $indx_md5.";".$md5.";".$sha.";".lc($verdict).";\n";		
		#print packet_file_verdicts $md5.";".$sha.";".lc($verdict).";\n";
		print packet_file_verdicts $md5.";".$sha.";".lc($verdict).";".$sha256.";\n";		
		#print "packet_file_verdicts = ".$md5.";".$sha.";".lc($verdict).";".$sha256.";\n";
		$indx_md5++;
		
		if ($indx_folder_file != $folder_size)
		{
			$indx_folder_file++;
		}
		
		if($indx_file_source == $packet_size)
		{
			print "create next file\n";
			print "indx_folder_file = ".$indx_folder_file."\n";
			print "folder_size = ".$folder_size."\n";
			$indx_packet_file++;	
			$indx_file_source=1;
			$indx_md5=1;	
						
			close(packet_file_md5s);
			close(packet_file_verdicts);
			if ($indx_folder_file == $folder_size)
			{
				print "create next folder\n";
				$indx_folder_file=1;
				$indx_packet_file=1;
				$hour++;
				if ($hour < 10)
				{
					$hour_str="0".$hour;
				}
				else
				{
					$hour_str=$hour;
				}
				if ($indx_md5_all != $folder_size_max)
				{
					mkdir ($path."/packet_files/packets_".$hour_str."_");
				}
			}
			if ($indx_md5_all != $folder_size_max)
			{
				open(packet_file_md5s,">> ".$path."/packet_files/packets_".$hour_str."_/packet_file_md5s_".$indx_packet_file."_.dat");
				open(packet_file_verdicts,">> ".$path."/packet_files/packets_".$hour_str."_/packet_file_verdicts_".$indx_packet_file."_.dat");			
				
			}
			#open(packet_file_md5s,">> ".$path."/packet_files/packet_file_md5s_".$indx_packet_file."_.dat");
			#open(packet_file_verdicts,">> ".$path."/packet_files/packet_file_verdicts_".$indx_packet_file."_.dat");
		}
		else
		{
			$indx_file_source++;
		}
		$indx_md5_all++;
	}	
	$rc = $sth -> finish;
	$dbh->disconnect;	
}
sub seach_params2
{
	(my $file,my $param) = @_;
	open(parameters, $file) or die "Error open file: $!";
	my $param_name;
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
	(my $string,my $number,my $delimeter) = @_;
	my @a=split("$delimeter", $string);
	my $value=$a[$number];
return $value;
}
