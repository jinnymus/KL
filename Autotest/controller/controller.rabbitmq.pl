#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use Socket;
use v5.10;
use JSON;
use MIME::Base64;
use LWP;
use Switch;

#my $request={"protocol", $proto, "data", $data};
my $browser = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => 'http://csn-backend-6:15672/api/queues');
$req->authorization_basic('guest', 'guest');
$req->content_type('text/xml');
#$req->content_type('application/json');
#$req->content(to_json( $request ));
my $result = $browser->request($req);
if ($result->is_success) 
{
	$response=from_json($result->content);
}
else 
{
	print $result->status_line, "\n";
}

my $mas=$response;

foreach my $line (@$mas)
{
	my $queue = $line->{"name"};
	my $service=cut($line->{"name"},"2",".");
	my $server=cut($line->{"name"},"3",".");
	#print "line = ".$line->{"name"}."\n";
	#print "queue = ".$queue." service = ".$service." server = ".$server."\n";
	print $server.".company.com;".$service.";".$queue.";\n";
}





sub cut
{
	(my $string,my $number,my $delimeter) = @_;
	my @a;
	if ($delimeter eq ".")
	{
		@a=split("\\.", $string);
	}
	else
	{
		@a=split("$delimeter", $string);
	}
	my $value=$a[$number];
	return $value;
}
sub seach_params2
{
	(my $file,my $param) = @_;
	print "[seach_params2] file = ".$file."\n";
	print "[seach_params2] param = ".$param."\n";
	open(parameters, $file) or die "Error open file: $!";
	my $param_name="";
	my $parameter;
	while(<parameters>) {
		$param_name=cut($_,"0","=");
		if ($param_name eq $param)
		{
			$parameter=cut($_,"1","=");
		}
	};
	close(parameters);
	chomp $parameter;
	print "[seach_params2] parameter = ".$parameter."\n";	
return $parameter;
}