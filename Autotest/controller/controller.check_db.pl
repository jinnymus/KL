#!/usr/bin/perl

use Time::localtime;
#use Time::HiRes;
use threads;
use v5.10;
use Switch;
use Socket;
use DBI;
use DBD::Sybase;
use v5.10;

sub handle_error {
    my $message = shift;
    #write error message wherever you want
    print "the message is '$message'\n";
	#print "mail\n";
    #exit; #stop the program
	unlink ("/file/file_sql_debug.html");
	open(file_sql_debug,"> /file/file_sql_debug.html");
	print file_sql_debug "SQL Fail message = ".$message."\n";
	print file_sql_debug "Added text = ".$message_add."\n";
	$mail_email_addreses=seach_params2('/file/parameters.dat','mail_email_addr_debug');
	print "mail_email_addreses = ".$mail_email_addreses."\n";
	$subject="File. Monitoring test - Consistency. Debug info - SQL Fail";
	$type="html";
	system("/file/_bin/controller.mail_send.pl /file/file_sql_debug.html \"$mail_email_addreses\" \"$subject\" \"html\"");
	close(file_sql_debug);
	unlink ("/file/file_sql_debug.html");
}

	
#my ($host,$port,$instance,$database,$user,$pass) = ("MSSQL","1433","SQLEXPRESS","PUB","KL\\kalistratov","Y6UHYziF");
my ($host,$port,$instance,$database,$user,$pass) = ("WLDATA","1433","SQLEXPRESS","WL","KL\\kalistratov","Y6UHYziF");
#my $user = q/KL\\kalistratov/;
#my $pass = q/Y6UHYziF/;
my $user = q/tester/;
my $pass = q/Test#$%Test/;
#my $table_name="#table".$$;

$dbh = DBI->connect("dbi:Sybase:server=$host;database=$database",$user,$pass,
{
       PrintError  => 0,
        HandleError => \&handle_error,
}
) or handle_error($DBI->errstr);


$dbh->syb_date_fmt('ISO');		
	
$sql_insert=$sql_insert."insert \@md5table( md5 ) values( 0x0d5fda661e2107b0d9ee0b3158059887    );\n";
	
	my $sql="declare \@md5table as MD5Table ".$sql_insert." CREATE TABLE $table_name (md5 binary(16), sha3 binary(20), TimeAdded datetime, LastZonechangeTime datetime, verdict nvarchar(32),isuploaded nvarchar(32));
								insert $table_name exec testing.File_Get_ByMd5 \@md5table = \@md5table;
								select * from $table_name order by md5;
								drop table $table_name;";
	

my $sth = $dbh->prepare($sql);
$sth -> execute();
#@rows = $sth->fetchrow_array();
my @rows;

while(@rows = $sth->fetchrow_array()) 
{ 
	
	#print $rows[0].";".$rows[1].";".$rows[2].";".$rows[3].";\n";
	my $md5=$rows[0];
	my $sha=$rows[1];
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
	print $md5.";".$sha.";".$timeadded_publisher.";".$lastchangetimezone_publisher.";".lc($rows[4]).";".$rows[5].";";
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

