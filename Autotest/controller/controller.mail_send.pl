#!/usr/bin/perl
use MIME::Lite;
use v5.10;
use Switch;
$mail_html_body=shift;
$mail_emails=shift;
$mail_subject=shift;
$mail_type=shift;
$debug_log=shift;
$mail_dir=shift;
print "mail_html_body = ".$mail_html_body."\n";
print "mail_emails = ".$mail_emails."\n";
print "mail_subject = ".$mail_subject."\n";
print "mail_type = ".$mail_type."\n";

open (html_body, $mail_html_body);
@html_body = <html_body>;
$text="";
foreach (@html_body)
{
	chomp $_;
	#print "line = ".$_."\n";
	$text = $text.$_."\n";
	#$msg->add('Data' => $_."\n");	
}
close(html_body);
$msg = MIME::Lite->new( From =>'mailer@csn_autotest.avp.ru',
						To =>$mail_emails,
						#Cc =>'Dmitry.Lukasevich@company.com',
						Subject =>$mail_subject,
						Type =>'text/html',
						Encoding =>'8bit',					
						Data =>$text
					  );
$msg->attr('content-type.charset' => 'windows-1251');			

if ($mail_type eq "multipart")		
{  
	print "debug_log = ".$debug_log."\n";
	print "mail_dir = ".$mail_dir."\n";
	$msg->attach( Type =>'text/html',
				Encoding =>'8bit',	
				Path =>$debug_log,
				Filename =>'debug.log'
				);
	#@files=`ls -d $mail_dir/*`;
	@files=`ls $mail_dir`;
	foreach (@files)
	{
		chomp $_;
		print "file ".$_." processed\n";
		$reversed = reverse $_;
		$ext_rev = cut($reversed,"0",".");
		$ext = reverse $ext_rev;
		print "file ".$_." type ".$ext."\n";				
		if ($ext eq "tar")		
		{
			$msg->attach( Type =>'application/x-compressed-tar',
				Path =>$mail_dir."/".$_,
				Filename =>$_
				);
		}
		elsif ($ext eq "gz")		
		{
			$msg->attach( Type =>'application/x-compressed-tar',
				Path =>$mail_dir."/".$_,
				Filename =>$_
				);
		}
		else
		{
			$msg->attach( Type =>'text/html',
				Encoding =>'8bit',	
				Path =>$mail_dir."/".$_,
				Filename =>$_
				);
		}
	}
}
else
{
	
}
MIME::Lite->send("sendmail", "/usr/sbin/sendmail -vt -oi -oem");
#$msg->send();
if ($msg->send) {
    print "Message has been sent\n";
}
else {
    print "Cannot send message\n", $MIME::Lite::VERSION."\n";
}
print "Mail was send.\n";
sub cut
{
	(my $string,my $number,my $delimeter) = @_;
	if ($delimeter eq ".")
	{
		@a=split /\./, $string;
	}
	else
	{
		@a=split("$delimeter",$string);
	}
	$value=$a[$number];
	return $value;
}