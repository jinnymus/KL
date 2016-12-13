#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use LWP::UserAgent;
use HTTP::Request;



$conf_name_kalistratov="cntlm_kalistratov.conf";
$conf_name_tester="cntlm_tester.conf";
$conf_path="/usr/local/etc";
#$proxy_local ='kalistratov:Y6UHYziD@proxy.avp.ru:3128'; 
$proxy_local ='10.65.67.128:3129'; 
$proxy_kalistratov ='10.65.67.131:3128'; 
	
sub check_proxy
{
	my $proxyurl=shift;
	chomp $proxyurl;
	my $url = 'http://www.google.com'; 
	print_log("[check_proxy] [".$proxyurl."] check url = ".$url);
	print_log("[check_proxy] [".$proxyurl."] define LWP::UserAgent");
	
	#use LWP::Protocol::https10 ();
	#LWP::Protocol::implementor('https', 'LWP::Protocol::https10');
	
	$lwp = LWP::UserAgent->new;
			
	$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
	$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;
	$ENV{HTTPS_PROXY} = $proxyurl;
	$ENV{HTTPS_DEBUG} = 1;
	$ENV{HTTPS_VERSION} = 3;
	$ENV{HTTPS_CA_DIR}    = '/etc/ssl/certs';
	$ENV{HTTPS_CA_FILE}    = '/etc/ssl/certs/ca_base64.crt';
	#$ENV{HTTP_PROXY} = $proxyurl;
	#$ENV{HTTPS_PROXY} = $proxyurl;
	
	$lwp->ssl_opts( verify_hostnames => 0 );
	print_log("[check_proxy] [".$proxyurl."] define proxy = ".$proxyurl);
	$lwp->proxy(['http','https'], 'http://'.$proxyurl);	# Можно и через проксю 

	print_log("[check_proxy] [".$proxyurl."] prepare request");
	$r = HTTP::Request->new(GET => "$url");
	#$r->proxy_authorization_basic("tester", "kf;0dsq Ntcnth");
	#$r->proxy_authorization_basic("kalistratov", "Y6UHYziD");
	print_log("[check_proxy] [".$proxyurl."] request");
	$response = $lwp->request($r);
	
	$status_request=0;
	$content="";
	
	print_log("[check_proxy] [".$proxyurl."] check response");
	if ($response->is_success)
	{
		
		print_log("[check_proxy] [".$proxyurl."] response SUCCESS");
		$status_request=1;
		#print $response->content;
		$content=$response->content;
	}
	else
	{
		
		print_log("[check_proxy] [".$proxyurl."] response ERROR");
		$status_request=2;
		print $response->error_as_HTML;
		$content=$response->content;
	}  
	@mas=();
	$mas[0]=$status_request;
	$mas[1]=$content;
	print_log("[check_proxy] [".$proxyurl."] end");
	return @mas;
}

sub change_config
{
	$config_name=shift;
	system("cp ".$conf_path."/".$config_name." ".$conf_path."/cntlm.conf");	
	$cntlm_pid=`/usr/local/etc/rc.d/cntlm status | cut -f 6 -d " " | cut -f 1 -d "."`;
	chomp $cntlm_pid;
	print_log("[change_config] cntlm_pid = ".$cntlm_pid);
	print_log("[change_config] config_name = ".$config_name);
	system("kill -9 ".$cntlm_pid);	
	system("/usr/local/etc/rc.d/cntlm start");	
}
print_log("[main] start check_proxy");
@mas_local=check_proxy($proxy_local);
@mas_kalistratov=check_proxy($proxy_kalistratov);
print_log("[main] end check_proxy");
$status_request_res_local=$mas_local[0];
$status_request_res_kalistratov=$mas_kalistratov[0];
$content_request_res_local=$mas_local[1];
$content_request_res_kalistratov=$mas_kalistratov[1];
print_log("[main] status_request_res_local = ".$status_request_res_local);
print_log("[main] status_request_res_kalistratov = ".$status_request_res_kalistratov);
#print_log("[main] content_request_res_local = ".$content_request_res_local);
#print_log("[main] content_request_res_kalistratov = ".$content_request_res_kalistratov);

print_log("[main] start check if");

if ($status_request_res_local == 2)
{
	print_log("[main] status_request_res1 == 2");
	print_log("[main] change_config conf_name_kalistratov");
	change_config($conf_name_kalistratov);
	@mas_res=check_proxy($proxy_kalistratov);
	$status_request_res2=$mas_res[0];
	$content_res2=$mas_res[1];
	print_log("[main] status_request_res2 = ".$status_request_res2);
	print_log("[main] content_res2 = ".$content_res2);
	if ($status_request_res2 == 2)
	{
		print_log("[main] status_request_res2 == 2");
		print_log("[main] change_config conf_name_tester");		
		change_config($conf_name_tester);
		$mail_email_addreses=seach_params2("/export/parameters.dat","mail_email_watchdog");
		print_log("[main] check_proxy_mail");				
		open(check_proxy_mail,"> /export/controller/check_proxy_mail");
		print check_proxy_mail "status_request_res2 = 2<br>\n";
		print check_proxy_mail "content<br>\n";
		print check_proxy_mail $content_res2."<br>\n";
		$shell="/export/controller/controller.mail_send.pl /export/controller/check_proxy_mail \"".$mail_email_addreses."\" \"Controller. Debug. Proxy fail\" \"html\"";
		print_log("[main] shell = ".$shell);				
		#system("/export/controller/controller.mail_send.pl /export/controller/check_proxy_mail ".$mail_email_addreses." \"Controller. Debug. Proxy fail\" \"html\"");
		$shell_res=`$shell`;
		close(check_proxy_mail);
		unlink("/export/controller/check_proxy_mail");
	}
	else
	{
		print_log("[main] check_proxy KALISTRATOV OK");		
	}
}
else
{
	print_log("[main] check_proxy LOCAL OK");		
}

#/usr/local/etc/rc.d/cntlm start

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
sub print_log
{
	my $message=shift;
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print "[DEBUG] [".$datetime_now."] [".$message."]\n";
}