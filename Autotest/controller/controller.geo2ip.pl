#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use Socket;
use v5.10;
#use strict;
#use warnings;

#$ENV{'SHELL'}="/bin/sh";
#$ENV{'P4PORT'}="pf.avp.ru:1666";
#$ENV{'P4CLIENT'}="controller_autotester_geoconf";
#$ENV{'P4HOST'}="controller_autotester";
#$ENV{'P4USER'}="Kalistratov";
#$ENV{'P4PASSWD'}="Avr999avr999";
#$ENV{'P4ROOT'}="/export/perforce/controller_autotester_geoconf";

#$proxy=seach_params2("/export/parameters.dat","proxy");
#$ENV{http_proxy}=$proxy;
#$ENV{'http_proxy'}=$proxy;
#$ENV{'https_proxy'}=$proxy;
#$ENV{https_proxy}=$proxy;
#$ENV{ftp_proxy}=$proxy;
#$ENV{SSL_verify_mod}="SSL_VERIFY_NONE";
#$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME}=0;

print "[main] start\n";
open(geo2ip_convert,"> /export/controller/geo2ip_convert.html");
$geo_files=seach_params2('/export/parameters.dat','geo_files');
$geo_mobile=seach_params2('/export/parameters.dat','geo_mobile');
$geo_dns=seach_params2('/export/parameters.dat','geo_dns');
$geo_geo=seach_params2('/export/parameters.dat','geo_geo');
$geo_url=seach_params2('/export/parameters.dat','geo_url');
$geo_path_url=seach_params2('/export/parameters.dat','geo_path_url');
$geo_path_file=seach_params2('/export/parameters.dat','geo_path_file');
$geo_services_path=seach_params2("/export/parameters.dat","geo_services");
$geo_servers_path=seach_params2('/export/parameters.dat','geo_servers');
$all_servers_path=seach_params2('/export/parameters.dat','all_servers');
$geo_services=$geo_services_path."/geo_services.dat";
$geo_servers=$geo_servers_path."/geo_servers.dat";
$all_dnses=$all_servers_path."/all_dnses.dat";
$all_servers=$all_servers_path."/all_servers.dat";
$all_ip=$all_servers_path."/all_ip.dat";
#unlink ($geo_services);
print "[main] geo_services = ".$geo_services."\n";
print "[main] geo_servers = ".$geo_servers."\n";
print "[main] all_dnses = ".$all_dnses."\n";
print "[main] all_servers = ".$all_servers."\n";
delete_tmp_files($geo_path_url,"conf");
my $wget_result=download_dns_conf();
print "[main] wget_result = ".$wget_result."\n";

@geo_servers=();
@mobile_servers=();
@dns_servers=();

@all_dnses_mas=();
@all_servers_mas=();
@all_services_mas=();
@all_ip_mas=();

if ($wget_result == 1)
{
	print "[main] wget_result = ".$wget_result."\n";
	convert_dns_file(*geo_servers,*all_servers_mas,*all_dnses_mas,*all_ip_mas);


	custom_servers_get($geo_mobile,"mobile",*mobile_servers,*all_servers_mas,*all_dnses_mas,*all_ip_mas);
	custom_servers_get($geo_dns,"dns",*dns_servers,*all_servers_mas,*all_dnses_mas,*all_ip_mas);

	#delete_tmp_files($geo_files,"mobile");
	#delete_tmp_files($geo_files,"custom");
	#process_custom_servers($geo_mobile,"mobile",*mobile_servers);
	#process_custom_servers($geo_dns,"custom",*dns_servers);

	print "[main] all_servers_mas count = ".scalar(@all_servers_mas)."\n";
	print "[main] all_dnses_mas count = ".scalar(@all_dnses_mas)."\n";
	print "[main] all_ip_mas count = ".scalar(@all_ip_mas)."\n";


	open(geo_servers,"> ".$geo_servers);
	@dns_servers_sort = sort (@dns_servers);
	foreach my $server (@dns_servers_sort)
	{
		chomp $server;
		print geo_servers $server."\n";
	}	
	@geo_servers_sort = sort (@geo_servers);
	foreach my $server (@geo_servers_sort)
	{
		chomp $server;
		print geo_servers $server."\n";
	}	
	@mobile_servers_sort = sort (@mobile_servers);
	foreach my $server (@mobile_servers_sort)
	{
		chomp $server;
		print geo_servers $server."\n";
	}	
	close(geo_servers);

	print "[main] print all_dnses_mas count = ".scalar(@all_dnses_mas)."\n";
	print "[main] print all_dnses = ".$all_dnses."\n";

	open(all_dnses_file,"> ".$all_dnses);	
	@all_dnses_mas_sort=sort(@all_dnses_mas);
	foreach my $dns (@all_dnses_mas_sort)
	{
		chomp $dns;
		print "[main] all_dnses_mas dns = ".$dns."\n";	
		print all_dnses_file $dns."\n";
	}
	close(all_dnses_file);	

	print "[main] print all_servers_mas count = ".scalar(@all_servers_mas)."\n";
	print "[main] print all_servers = ".$all_servers."\n";

	open(all_servers_file,"> ".$all_servers);	
	@all_servers_mas_sort=sort(@all_servers_mas);
	foreach my $server (@all_servers_mas_sort)
	{
		chomp $server;
		print "[main] all_servers_mas server = ".$server."\n";		
		print all_servers_file $server."\n";
	}
	close(all_servers_file);

	print "[main] print all_ip count = ".scalar(@all_ip)."\n";
	print "[main] print all_ip = ".$all_ip."\n";

	open(all_ip_file,"> ".$all_ip);	
	@all_ip_mas_sort=sort(@all_ip_mas);
	foreach my $ip (@all_ip_mas_sort)
	{
		chomp $ip;
		print "[main] all_ip ip = ".$ip."\n";		
		print all_ip_file $ip."\n";
	}
	close(all_ip_file);
}

sub process_perforce
{

	@p4infores=`/usr/local/bin/p4 info`;
	print geo2ip_convert "P4 info result:<br>\n";
	print geo2ip_convert "------------<br>\n";
	foreach $line (@p4infores)
	{
		chomp($line);
		print geo2ip_convert $line."<br>\n";	
		print "info line = ".$line."\n";
	}
	print geo2ip_convert "------------\n";
	@p4syncres=`/usr/local/bin/p4 sync -f`;
	print geo2ip_convert "P4 sync result:<br>\n";
	print geo2ip_convert "------------<br>\n";
	foreach $line (@p4syncres)
	{
		chomp($line);
		print geo2ip_convert $line."<br>\n";
		print "[process_perforce] sync line = ".$line."\n";	
	}
	print geo2ip_convert "------------<br>\n";
	if (!grep(/refreshing/,@p4syncres))
	{

		my $mail_email_addreses=seach_params2('/export/parameters.dat','mail_email_addreses');
		#print_time($debug_file, "mail_email_addreses = ".$mail_email_addreses."\n";
		my $subject="Controller. P4 Sync. Debug info - Sync fail";
		#my $type="html";
		system ("/export/controller/controller.mail_send.pl /export/controller/geo2ip_convert.html \"".$mail_email_addreses."\" \"".$subject."\" html");

		#unlink ("/export/controller/geo2ip_convert.html");	
	}
	else
	{
		print "[process_perforce] Syc OK\n";
	}
	close(geo2ip_convert);
	
	print "------------\n";
	$geo_perforce_path=seach_params2('/export/parameters.dat','geo_perforce_path');
	print "geo_perforce_path = ".$geo_perforce_path."\n";

	opendir(geo_perforce_dir, $geo_perforce_path);
	@geo_perforce_files_all= readdir(geo_perforce_dir); 
	@geo_perforce_files=grep(/yaml/,@geo_perforce_files_all);
	$dns_csn_allservers=$geo_files."/allservers.dat";
	$geo_servers=$geo_servers_path."/geo_servers.dat";
	$all_servers=$all_servers_path."/all_servers.dat";
	
	print "dns_csn_allservers = ".$dns_csn_allservers."\n";			
	print "geo_services = ".$geo_services."\n";			
	print "geo_servers = ".$geo_servers."\n";			
	print "all_servers = ".$all_servers."\n";			
	
	unlink($dns_csn_allservers);
	#unlink($geo_servers);
	#unlink($all_servers);
		
	@csn_allservers=();
	my @all_services_mas=();
	@geo_services_mas=();
	
	unlink($geo_services);
	print "start processing normal servers\n";
	foreach $geofile (@geo_perforce_files)
	{
		chomp($geofile);
		print "converting file ".$geofile."\n";
		my $len_geofile=length($geofile);
		my $service=substr($geofile,8,$len_geofile);
		$service=reverse($service);
		$len_line=length($service);
		$service=substr($service,5,$len_line);
		$service=reverse($service);		
		if (!grep (/$service/,@all_services_mas))
		{
			push (@all_services_mas,$service);
		}			
		convert_file($geo_files,$geo_perforce_path."/".$geofile,*csn_allservers,*geo_services_mas);
	}
	print "geo_services_mas count =".scalar(@geo_services_mas)."\n";
	print "end processing normal servers\n";

}

sub print_custom_file
{
	my $filename=shift;
	my $text=shift;
	my $type=shift;
	
	open (datfile,">> ".$geo_files."/csn-".$filename);
	print datfile $text."\n";
	close (datfile);
}

sub delete_tmp_files
{
	my $dir=shift;
	my $files=shift;
	#my $path="/file";
	#my $path=seach_params2("/file/parameters.dat","test_testname_basic");	
	print "[delete_tmp_files] dir = ".$dir."\n";
	print "[delete_tmp_files] files = ".$files."\n";
	opendir(DIR, $dir);
	my @FILES= readdir(DIR); 
	print "[delete_tmp_files] count files = ".scalar(@FILES)."\n";
	my @files_for_delete=grep(/$files/,@FILES);
	foreach my $file (@files_for_delete)
	{
		print "[delete_tmp_files] file = ".$dir."/".$file."\n";	
		unlink($dir."/".$file);
	}
}

sub custom_services_get
{
	opendir(geo_dns_services_dir, $geo_dns);
	print "geo_dns_services = ".$geo_dns."\n";	
	my @geo_dns_services_files_all= readdir(geo_dns_services_dir); 
	my @geo_dns_services_file_dat=grep(/ser/,@geo_dns_services_files_all);
	print "count geo_dns_services_files_all = ".scalar(@geo_dns_services_files_all)."\n";
	print "count geo_dns_services_file_dat = ".scalar(@geo_dns_services_file_dat)."\n";	
	my @custom_services=();
	my $i=0;	
	foreach my $file (@geo_dns_services_file_dat)
	{
		print "[custom_services] ".$file."\n";
		open(file,$geo_dns."/".$file);
		my @file=<file>;
		$file_service=cut($file,"1",".");
		foreach my $line (@file)
		{
			chomp $line;
			print "[custom_services] file = ".$file." file_service = ".$file_service." line = ".$line."\n";			
			$custom_services[$i][0]=$file;
			$custom_services[$i][1]=$file_service;
			$custom_services[$i][2]=$line;			
			$i++;
		}
		close(file);		
	}	
	return (@custom_services);	
}

sub custom_servers_get
{
	my $dir=shift;
	my $type=shift;
	*servers=shift;
	*all_servers_mas=shift;
	*all_dnses_mas=shift;
	*all_ip_mas=shift;
	
	opendir(geo_dns_dir, $dir);
	print "[custom_servers_get] dir = ".$dir."\n";
	print "[custom_servers_get] type = ".$type."\n";
	
	my @geo_dns_files_all= readdir(geo_dns_dir); 
	my @geo_dns_file_dat=grep(/dat/,@geo_dns_files_all);
	print "[custom_servers_get] count geo_dns_files_all = ".scalar(@geo_dns_files_all)."\n";
	print "[custom_servers_get] count geo_dns_file_dat = ".scalar(@geo_dns_file_dat)."\n";
	#my @custom_servers=();
	#my $i=0;
	foreach my $file (@geo_dns_file_dat)
	{
		print "[custom_servers] file = ".$file."\n";
		open(file,$dir."/".$file);
		my @file=<file>;
		foreach my $dns (@file)
		{
			chomp $dns;
			print "[custom_servers] dns from file = ".$dns."\n";
			@addresses = gethostbyname($dns);
			@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
			foreach my $ip (@addresses)
			{
				chomp $ip;
				my $host = get_host_name($ip);
				my $service_name=cut($file,"0",".");
				print "[custom_servers] type = ".$type." service_name = ".$service_name." file = ".$file." host = ".$host." ip = ".$ip." dns = ".$dns."\n";
				push @servers, $type.";".$service_name.";".$host.";".$ip.";".$dns."\n";
				if (!grep(/$host/,@all_servers_mas))
				{
					push @all_servers_mas, $host;
				}
				if (!grep(/$dns/,@all_dnses_mas))
				{
					push @all_dnses_mas, $dns;
				}	
				if (!grep(/$ip/,@all_ip_mas))
				{
					push @all_ip_mas, $ip;
				}	
				#$custom_servers[$i][0]=$file;
				#$custom_servers[$i][1]=$line;
				#$custom_servers[$i][2]=$adr;
				#$custom_servers[$i][3]=$name;
				#$i++;
			}
		}
		close(file);
	}
	@custom_servers=sort(@custom_servers);
	return (@custom_servers);
}

sub getip
{
	my $host=shift;
	print "[getip] host = ".$host."\n";
	my @addresses = gethostbyname($host);
	@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
	my $result=$addresses[0];
	#foreach $adr (@addresses)
	#{
	#	chomp $adr;
	#	my $result=
	#}
	return $result;
}

sub process_custom_servers
{
	my $dir=shift;
	my $type=shift;
	*servers=shift;
	
	opendir(geo_dns_dir, $dir);
	print "dir = ".$dir."\n";
	my @geo_dns_files_all= readdir(geo_dns_dir); 
	my @geo_dns_file_dat=grep(/dat/,@geo_dns_files_all);
	print "[process_custom_servers] count geo_dns_files_all = ".scalar(@geo_dns_files_all)."\n";
	print "[process_custom_servers] count geo_dns_file_dat = ".scalar(@geo_dns_file_dat)."\n";

	foreach my $file (@geo_dns_file_dat)
	{
		print_custom_file($file,"<html><table colspan=3 border=1><tr><td><b>DNS</b></td><td><b>IP</b></td><td><b>Name</b></td></tr>",$type);
	}

	my $i=0;
	foreach my $line (@servers)
	{
		my $type=cut($line,"0",";");
		my $service_name=cut($line,"1",";");
		my $host=cut($line,"2",";");
		my $ip=cut($line,"3",";");
		my $dns=cut($line,"4",";");
		
		print "[process_custom_servers] type = ".$type." service_name = ".$service_name." host = ".$host." ip = ".$ip." dns = ".$dns."\n";
		print_custom_file($servers[$i][0],"<tr><td>".$servers[$i][1]."</td><td>".$servers[$i][2]."</td><td>".$servers[$i][3]."</td></tr>",$type);
		$i++;
	}
	foreach my $file (@geo_dns_file_dat)
	{
		print_custom_file($file,"</table></html>",$type);
	}
}

sub get_host_name
{
	#print "[get_host_name] start\n";
	my $ip=shift;
	#print "[get_host_name] ip = ".$ip."\n";
	my $found;
	opendir(dir, "/export/controller/servers_hosts");
	@dir_files_all= readdir(dir); 
	@dir_files=grep(/dat/,@dir_files_all);
	#print "[get_host_name] foreach\n";
	$found_code=0;
	foreach my $file (@dir_files)
	{
		#print "[get_host_name] file = ".$file."\n";
		open(file,"/export/controller/servers_hosts/".$file);
		my @file=<file>;
		foreach my $line (@file)
		{
			chomp($line);
			#print "[get_host_name] line = ".$line."\n";
			$name=cut($line,"0",";");
			my @addresses = gethostbyname($name);
			@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
			if ($addresses[0] eq $ip)
			{
				$found=$name;
				$found_code=1;
				last;
			}
			if ($found_code == 1)
			{
				last;
			}
		}
		close(file);
	}
	if ($found eq "")
	{
		$found="none";
	}
	#print "[get_host_name] found = ".$found."\n";
	#print "[get_host_name] end\n";
	return $found;
}
sub convert_file
{
	$geo_files=shift;
	$file=shift;
	*csn_allservers=shift;
	*geo_services_mas=shift;
	
	print "[convert_file] dns_csn_allservers = ".$dns_csn_allservers."\n";				
	open(file,$file);
	my @file=<file>;
	my @servers=();
	my @custom_service=();
	foreach $line (@file)
	{
		chomp($line);
		if ($line=~m/#/)
		{
			print "# detected line = ".$line."\n";		
			next;
		}
		if ($line=~m/    -/)
		{
			#print "line = ".$line."\n";
			$server=cut(cut($line,"5"," "),"0",":");
			#print "server = ".$server."\n";
			if (grep(/$server/,@servers))
			{
				#print "server ".$server." exist\n";
			}
			else
			{
				#print "server ".$server." not exist\n";
				push (@servers,$server);
			}
		}
	}
	$file_rev=reverse $file;
	#print "file_rev = ".$file_rev."\n";
	$file_geo_rev=cut($file_rev,"0","/");
	#print "file_geo_rev = ".$file_geo_rev."\n";
	$file_geo=reverse $file_geo_rev;
	#print "file_geo = ".$file_geo."\n";
	$service=cut($file_geo,"0",".");
	@servers_sort=sort(@servers);
	print "servers count = ".scalar(@servers)."\n";
	chomp ($service);
	print "service = ".$service."\n";
	open(out,"> ".$geo_files."/".$service.".dat");
	
	my $len_line=length($service);
	my $service_name=substr($service,8,$len_line);

	print "service_name = ".$service_name."\n";
	

	#open(geo_services,">> ".$geo_services);	

	foreach $server (@servers_sort)
	{
		if (!grep(/$server/,@csn_allservers))
		{
			push @csn_allservers, $server;
		}
		
		print out $server.".company.com\n";
		#print geo_services $service_name.";".$server.".company.com;\n";
		my $host=$server.".company.com";
		my $ip=getip($host);
		my $service_ip_name;
		$service_ip_name=$service_name.";".$name.";".$ip;
		print "[convert_file] server = ".$server." host = ".$host." ip = ".$ip."\n";
		if (!grep (/$service_ip_name/,@geo_services_mas))
		{
			push (@geo_services_mas,$service_name.";".$host.";".$ip);
		}
	}
	close(out);
	close(file);
}

sub download_dns_conf
{
	$shell_wget="/usr/local/bin/wget -P ".$geo_path_url." ".$geo_url." 2>&1";
	print "[download_dns_conf] shell_wget = ".$shell_wget."\n";
	print "[download_dns_conf] check path = ".$geo_path_file."\n";
	
	my @wget=`$shell_wget`;
	if (-e $geo_path_file)
	{
		return 1;
	}
	else
	{
		foreach my $line (@wget)
		{
			chomp $line;
			print "[download_dns_conf] wget line = ".$line."\n";
		}
		return 0;
	}
}

sub convert_dns_file
{
	*services=shift;
	*all_servers_mas=shift;	
	*all_dnses_mas=shift;
	*all_ip_mas=shift;
	
	open(fileconf,$geo_path_file);
	my @fileconf=<fileconf>;
	my @services_full=grep(/service/,@fileconf);

	foreach my $services_full_line (@services_full)
	{
		chomp $services_full_line;
		my $service=cut(cut($services_full_line,"2"," "),"1","-");
		unlink ($geo_geo."/".$service.".dat");
	}

	print "[convert_dns_file] count services = ".scalar(@services)."\n";

	foreach my $service (@services)
	{
		print "[convert_dns_file] service = ".$service."\n";
	}
	
	foreach my $line (@fileconf)
	{
		chomp $line;
		if (grep (/region/, $line))
		{
			next;
		}
		elsif (grep (/service/, $line))
		{
			$service_name=cut(cut($line,"2"," "),"1","-");
		}
		else
		{
			my $host=cut($line,"3"," ");
			print "[convert_dns_file] host = ".$host." service_name = ".$service_name."\n";
			my $line="geo;".$service_name.";".$host.";";
			if (!grep (/$line/,@services))
			{
				my $ip=getip($host);
				my $dns="csn-".$service_name."-geo.company.com";
				print "[convert_dns_file] push = geo;".$service_name.";".$host.";".$ip.";csn-".$service_name."-geo.company.com\n";
				push @services, "geo;".$service_name.";".$host.";".$ip.";".$dns."\n";
				if (!grep(/$host/,@all_servers_mas))
				{
					push @all_servers_mas, $host;
				}				
				if (!grep(/$dns/,@all_dnses_mas))
				{
					push @all_dnses_mas, $dns;
				}				
				if (!grep(/$ip/,@all_ip_mas))
				{
					push @all_ip_mas, $ip;
				}					
			}
			else
			{
				#print "exist host = ".$host." service_name = ".$service_name."\n";
			}
		}
	}
	print "[convert_dns_file] count services ".scalar(@services)."\n";
	foreach my $service_line (@services)
	{
		chomp $service_line;
		#print "[convert_dns_file] service_line ".$service_line."\n";
		my $service_name=cut($service_line,"1",";");
		open (file, ">> ".$geo_geo."/".$service_name.".dat");
		my $type=cut($service_line,"0",";");
		my $host=cut($service_line,"2",";");
		my $ip=cut($service_line,"3",";");
		my $geodns=cut($service_line,"4",";");
		print "[convert_dns_file] massive type = ".$type." service_name = ".$service_name." host = ".$host." ip = ".$ip." geodns = ".$geodns."\n";
		print file $service_line."\n";
		close(file);
	}
	close(fileconf);
}

sub geo_check
{
	my $server=shift;
	my @result=();
	print "[geo_check] server = ".$server."\n";
	my  $geo_files_dir=seach_params2('/export/parameters.dat','geo_files');
	#print "geo_files_dir = ".$geo_files_dir."\n";
	opendir(geo_files_dir, $geo_files_dir);
	my @geo_files_all= readdir(geo_files_dir); 
	#print "geo_files_all count = ".scalar(@geo_files_all)."\n";
	my  @geo_files=grep(/dns-csn/,@geo_files_all);
	#print "geo_files count = ".scalar(@geo_files)."\n";
	my $geofile;
	foreach $geofile (@geo_files)
	{
		chomp ($geofile);
		open(file,$geo_files_dir."/".$geofile);
		my @file=<file>;
		if (grep(/$server/,@file))
		{
			print "[geo_check] server = ".$server." geofile = ".$geofile."\n";
			push @result, $geofile;
		}
		close(file);
	}
	return @result;
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
sub process_dat_files
{
	opendir(files, $path."/results");
	@results = readdir(RESULTS); 
}