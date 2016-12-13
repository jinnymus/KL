#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use HTTP::Request;
use MIME::Base64 ();
use MIME::Base64;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);
use Encode;
use Unicode::String;
use bytes;
use Switch;
use threads;
use Socket;
use DBI;
use DBD::Sybase;

unlink ("/export/ncsn/pub_insert.log");
	
$flow=shift;	
print_time("flow = ".$flow);
	
BEGIN 
{ 
	$ENV{SYBASE} = "/usr/local"; 
}

my ($host,$port,$instance,$database,$user,$pass) = ("MSSQL_TEST","1433","SQLEXPRESS","PUB_TEST","KL\\kalistratov","Y6UHYziF");
#my $user = q/KL\\kalistratov/;
#my $pass = q/Y6UHYziF/;
my $user = q/sa/;
my $pass = q/sasasa/;
my $dbh_check = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
	{
		PrintError  => 0,
		HandleError => \&handle_error,
	}
	) or handle_error($DBI->errstr);
#my $dbh_check->syb_date_fmt('ISO');			

#insert($dbh_check,"e3b08897780ce43fd50e5242de150f28","bad");

opendir(DIR, "/file/packet_files");
#opendir(DIR, "/export/test");
my @dirs= readdir(DIR); 
@dirs_hours=grep(/packet/,@dirs);
my $count_dirs=scalar(@dirs_hours);
print_time("count_dirs = ".$count_dirs);

foreach my $dir_hour (@dirs_hours)
{
	chomp $dir_hour;
	print_time("dir_hour = ".$dir_hour." processing");
	opendir(DIR2, "/file/packet_files/".$dir_hour);
	my @dirs2= readdir(DIR2); 
	@files=grep(/packet_file_verdicts/,@dirs2);
	foreach my $file (@files)
	{
		chomp $file;	
		print_time("dir_hour = ".$dir_hour." file = ".$file." processing");
		open(file,"/file/packet_files/".$dir_hour."/".$file);
		my @file=<file>;
		foreach my $line (@file)
		{
			chomp $line;
			my $md5=cut($line,"0",";");
			my $verdict=cut($line,"2",";");
			#print "md5 = ".$md5." verdict = ".$verdict."\n";
			if ($flow eq "HIPS")
			{
				insert($dbh_check,$md5,$verdict);
			}
			elsif ($flow eq "WOC")
			{
				insert_woc($dbh_check,$md5);
			}			
		}
	}
}

$dbh_check->disconnect;
	
sub print_time
{
	$text=shift;
	$tm_now = localtime;
	$datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	open (file,">> /export/ncsn/pub_insert.log");
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
	print file "[DEBUG] [".$datetime_now."] [".$text."]\n";
	close(file);
}	
sub cut
{
	( my $string,my $number,my $delimeter) = @_;
	@a=split("$delimeter", $string);
	$value=$a[$number];
return $value;
}	
sub insert
{
	my $dbh_check=shift;
	my $md5=shift;
	my $verdict=shift;
	
	my $bin = pack "H*", $md5;
	my $encoded = encode_base64($bin);

	if ($verdict eq "bad")
	{
		$policy="AAAAAAMAAAAAAAAAAAAAAA==";
	}
	else
	{
		$policy="AAAAAAAAAAAAAAAAAAAAAA==";
	}
	chomp $encoded;
			
	my $sql_audit="declare 
	\@myid varchar(36) = (CAST(NEWID() AS VARCHAR(36))),
	\@date varchar(36) = (CAST(convert(NVARCHAR, getdate(), 127) AS VARCHAR(36))),
	\@msg xml;
	SET \@msg = '<root send_date=\"' + \@date + '\" message_guid=\"' + \@myid + '\">
	<operation>1</operation>
	<md5>".$encoded."</md5>
	<hips policy=\"".$policy."\" />
	<file name=\"bABvAGEAZABpAG4AZwAuAHAAaABwAA==\" size=\"23454\" regDate=\"2014-04-27T23:43:00\" trustedZoneLevel=\"0\" />
	</root>'
	insert into audit.Msg values (\@date,\@myid,5,1,\@msg);";
			
	my $sql="declare 
	\@myid varchar(36) = (CAST(NEWID() AS VARCHAR(36))),
	\@date varchar(36) = (CAST(convert(NVARCHAR, getdate(), 127) AS VARCHAR(36))),
	\@msg xml;
	SET \@msg = '<root send_date=\"' + \@date + '\" message_guid=\"' + \@myid + '\">
	<operation>1</operation>
	<md5>".$encoded."</md5>
	<hips policy=\"".$policy."\" />
	<file name=\"bABvAGEAZABpAG4AZwAuAHAAaABwAA==\" size=\"23454\" regDate=\"2014-04-27T23:43:00\" trustedZoneLevel=\"0\" />
	</root>'
	--select \@msg;
	exec dbo.msg_send		
	  \@dataflow           = 'HIPS',  
	  \@msg                = \@msg,  
	  \@contract           = 'http://company.com/WL/HipsByNfsContract',
	  \@message_type_name  = 'http://company.com/WL/HipsMessage'";
	  
	#print $sql."\n";
	my $sth = $dbh_check->prepare($sql_audit);
	$sth -> execute();
	#my @rows;
	#while(@rows = $sth->fetchrow_array()) 
	#{ 
		#print $rows[0]."\n";
		#print $rows[0].";".$rows[1].";".$rows[2].";".$rows[3].";\n";
	#}		
	$sth -> finish;
}
sub insert_woc
{
	my $dbh_check=shift;
	my $md5=shift;
	
	my $bin = pack "H*", $md5;
	my $encoded = encode_base64($bin);

	chomp $encoded;
			
	my $sql_audit="declare 
	\@myid varchar(36) = (CAST(NEWID() AS VARCHAR(36))),
	\@date varchar(36) = (CAST(convert(NVARCHAR, getdate(), 127) AS VARCHAR(36))),
	\@msg xml;
	SET \@msg = '<root send_date=\"' + \@date + '\" message_guid=\"' + \@myid + '\">
	<operation>3</operation>
	<md5>".$encoded."</md5>
	<woc><userCount>1</userCount>
	<firstRequestTime>2012-06-01T20:01:00</firstRequestTime>
	<groupSharing trusted=\"100\" lowRest=\"1\" hiRest=\"99\" untrusted=\"0\"/>
	<geoSharing><item countryCode=\"ru\" percent=\"16\" />
	</geoSharing></woc></root>'
	insert into audit.Msg values (\@date,\@myid,4,3,\@msg);";
			

	  
	#print $sql."\n";
	my $sth = $dbh_check->prepare($sql_audit);
	$sth -> execute();
	#my @rows;
	#while(@rows = $sth->fetchrow_array()) 
	#{ 
		#print $rows[0]."\n";
		#print $rows[0].";".$rows[1].";".$rows[2].";".$rows[3].";\n";
	#}		
	$sth -> finish;
}
sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";
	
    exit; #stop the program
}