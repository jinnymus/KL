#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use HTTP::Request;
use MIME::Base64 ();
use MIME::Base64;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);


print "####################################################################################################################\n";
print "start\n";
print "###########\n";

post();

sub post
{
	$verdict="test verdict";
	$verdict_encode = MIME::Base64::encode($verdict);
	$proxy_local ='10.65.67.128:3129'; 
	$proxy_kalistratov ='172.16.6.124:3128'; 
	#$server ='62.128.100.84'; 
	$server ='62.128.100.84';
	$port ='80'; 
	$url = "http://".$server."/cgi-bin/cv_receiver.cgi";
	#$md5="Pm1a96xKS6FM3d3HCRYLkA==";
	#$md5="o44XcfdBP03/Y52626ipGw==";
	#$md5="4Ed/Hm+zCw91lVACLoFfwQ==";
	#$policy="AAAAAAMAAAAAAAAAAAAAAA==";
	$policy="AAAAAAAAAAAAAAAAAAAAAA==";
	$guid="FEF481D6-F8D4-461F-9DC0-3A0242CFE8EB";

	$xml="<request>";
	$xml=$xml."<root dns_name=\"test.company.com\"  send_date=\"2012-12-05T13:07:00.693\" message_guid=\"".$guid."\">";
	$xml=$xml."<state>2</state>";
	$xml=$xml."<rec_id>1</rec_id>";
	$xml=$xml."<rec_type>0</rec_type>";
	$xml=$xml."<rec_revision>1</rec_revision>";
	$xml=$xml."<verdict_name>".$verdict_encode."</verdict_name>";
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