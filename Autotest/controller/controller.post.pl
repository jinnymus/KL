#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use HTTP::Request;
use MIME::Base64 ();
use MIME::Base64;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);


$test="Hello, Worlvvddddddddv!";
$md5_string="15DBDDBDBF8AD43C2D13DA0CC921C35";
$md5_string_test="9DEF879C760983980FA4A8EBE05BE9C8";
$md5_string_test_encode="ne+HnHYJg5gPpKjr4FvpyA==";
#$md5_test2="91HqUFMy2UbuMSGrvb9svw==";
$md5_encode = MIME::Base64::encode($md5_string);
#$md5_encode_test = MIME::Base64::encode($md5_string_test);
$md5_encode_test = md5_base64($md5_string_test);
#$md52 = encode_base64($md5_string);
#$md53 = md5_base64($md5_string);
#$md54 = md5_hex($md5_string);
$md5_test_encode=md5_hex($test);
hex2bin($md5_test_encode);
$md5_test_encode_bin=md5($test);
#$test_encode = md5_base64($test);
$test_encode = md5_base64($md5_test_encode_bin);
$md5_encode = MIME::Base64::encode($md5_test_encode);
#$test_encode .= "==";

$ctx = Digest::MD5->new;
$ctx->add($test);
 
print $ctx->digest."\n";
print $ctx->hexdigest."\n";
print $ctx->b64digest."\n";
 
chomp ($md5_encode);
chomp ($md5_encode_test);
chomp ($test_encode);
#$md5_decoded = MIME::Base64::decode($md5_test);
#$md5_decoded2 = MIME::Base64::decode($md5_test2);

print "####################################################################################################################\n";
#print "md5 md5_string = ".$md5_string."\n";
#print "md5 md5_string test = ".$md5_string_test."\n";
#print "md5 encoded = ".$md5_encode."\n";
#print "md5 encoded test = ".$md5_encode_test."\n";
#print "md5 md5_string_test_encode = ".$md5_string_test_encode."\n";
#print "md5 encoded2 = ".$md52."\n";
#print "md5 encoded3 = ".$md53."\n";
#print "md5 encoded4 = ".$md54."\n";
#print "md5 test decoded = ".$md5_decoded."\n";
#print "md5 test decoded2 = ".$md5_decoded2."\n";
print "md5_test_encode = ".$md5_test_encode."\n";
#print "md5_test_encode_bin = ".$md5_test_encode_bin."\n";
print "test_encode = ".$test_encode."\n";
print "md5 encoded = ".$md5_encode."\n";
print "###########\n";

post($md5_encode);

sub post
{
	$md5=shift;
	$proxy_local ='10.65.67.128:3129'; 
	$proxy_kalistratov ='172.16.6.124:3128'; 
	#$server ='62.128.100.84'; 
	$server ='10.65.66.200';
	$port ='80'; 
	$url = "http://".$server."/cgi-bin/hips_receiver2.cgi";
	#$md5="Pm1a96xKS6FM3d3HCRYLkA==";
	#$md5="o44XcfdBP03/Y52626ipGw==";
	#$md5="4Ed/Hm+zCw91lVACLoFfwQ==";
	#$policy="AAAAAAMAAAAAAAAAAAAAAA==";
	$policy="AAAAAAAAAAAAAAAAAAAAAA==";
	$guid="FEF481D6-F8D4-461F-9DC0-3A0242CFE8EB";

	$xml="<request>";
	$xml=$xml."<root dns_name=\"test.company.com\"  send_date=\"2012-12-05T13:07:00.693\" message_guid=\"".$guid."\">";
	$xml=$xml."<operation>1</operation>";
	$xml=$xml."<md5>".$md5."</md5>";
	$xml=$xml."<hips policy=\"".$policy."\" />";
	$xml=$xml."<file regDate=\"2012-12-05T13:06:00\" trustedZoneLevel=\"0\" size=\"61000\" />";
	$xml=$xml."</root>";
	$xml=$xml."</request>";

	use LWP::UserAgent;
	$ua = LWP::UserAgent->new;
	#$ua->proxy(['http'], 'http://' . $proxy_kalistratov);	# Можно и через проксю 
	my $req = HTTP::Request->new(GET=>$url);
	$req->authorization_basic('admin', 'admin');
	$req->content_type('text/xml');
	$req->content($xml);
	$req->header("Content-Length", length($xml));
	my $res = $ua->request($req);
		
	print "Content-type: text/html\n\n";
	print "\nsimple\n====================\n";
	print $res->content;
	print "\nfull\n====================\n";
	print $res->as_string;
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