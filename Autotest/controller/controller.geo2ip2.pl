#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use Socket;
use v5.10;
use JSON;
use MIME::Base64;
use LWP;

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
print_time("[main] start");
#create_host_names();
#exit;
#get_host_name("62.128.100.109");
#exit;

open(geo2ip_convert,"> /export/controller/geo2ip_convert.html");
$geo_files=seach_params2('/export/parameters.dat','geo_files');
$geo_mobile=seach_params2('/export/parameters.dat','geo_mobile');
$geo_ctms=seach_params2('/export/parameters.dat','geo_ctms');
$geo_kavsdk=seach_params2('/export/parameters.dat','geo_kavsdk');
$geo_dns=seach_params2('/export/parameters.dat','geo_dns');
$geo_geo=seach_params2('/export/parameters.dat','geo_geo');
$geo_url=seach_params2('/export/parameters.dat','geo_url2');
$geo_path_url=seach_params2('/export/parameters.dat','geo_path_url');
$geo_path_file=seach_params2('/export/parameters.dat','geo_path_file2');
$geo_services_path=seach_params2("/export/parameters.dat","geo_services");
$geo_servers_path=seach_params2('/export/parameters.dat','geo_servers');
$all_servers_path=seach_params2('/export/parameters.dat','all_servers');
print_time("[main] geo_services_path = ".$geo_services_path);
$geo_services=$geo_services_path."/geo_services.dat";
print_time("[main] geo_services = ".$geo_services);
$geo_servers=$geo_servers_path."/geo_servers.dat";
$all_dnses=$all_servers_path."/all_dnses.dat";
$all_servers=$all_servers_path."/all_servers.dat";
$table=$all_servers_path."/table.html";
$tabledat=$all_servers_path."/table.dat";
$table_final=$all_servers_path."/table_final.dat";
$table_rabbit=$all_servers_path."/table_rabbit.dat";
$all_ip=$all_servers_path."/all_ip.dat";
#unlink ($geo_services);


print_time("[main] geo_services = ".$geo_services);
print_time("[main] geo_servers = ".$geo_servers);
print_time("[main] all_dnses = ".$all_dnses);
print_time("[main] all_servers = ".$all_servers);
print_time("[main] call create_host_names");
create_host_names();
delete_tmp_files($geo_path_url,"conf");
my $wget_result=download_dns_conf();
print_time("[main] wget_result = ".$wget_result);

@geo_servers=();
@mobile_servers=();
@ctms_servers=();
@kavsdk_servers=();
@dns_servers=();

@all_dnses_mas=();
@all_servers_mas=();
@all_services_mas=();
@all_ip_mas=();
$all_ip_mas_d=\@all_ip_mas;

@datacenters=("msk","fft","fft2","bjg","hkg","trt");

create_rabbbit_file();

if ($wget_result == 1)
{
	print_time("[main] wget_result = ".$wget_result);
	convert_dns_file(*geo_servers,*all_servers_mas,*all_dnses_mas,$all_ip_mas_d);
	custom_servers_get($geo_ctms,"ctms",*ctms_servers,*all_servers_mas,*all_dnses_mas,$all_ip_mas_d);
	custom_servers_get($geo_kavsdk,"kavsdk",*kavsdk_servers,*all_servers_mas,*all_dnses_mas,$all_ip_mas_d);
	custom_servers_get($geo_mobile,"mobile",*mobile_servers,*all_servers_mas,*all_dnses_mas,$all_ip_mas_d);
	custom_servers_get($geo_dns,"dns",*dns_servers,*all_servers_mas,*all_dnses_mas,$all_ip_mas_d);

	#delete_tmp_files($geo_files,"mobile");
	#delete_tmp_files($geo_files,"custom");
	#process_custom_servers($geo_mobile,"mobile",*mobile_servers);
	#process_custom_servers($geo_dns,"custom",*dns_servers);

	print_time("[main] all_servers_mas count = ".scalar(@all_servers_mas));
	print_time("[main] all_dnses_mas count = ".scalar(@all_dnses_mas));
	print_time("[main] all_ip_mas count = ".scalar(@all_ip_mas));

	unlink ($geo_servers);
	
	$dns_servers_d=\@dns_servers;
	$geo_servers_d=\@geo_servers;
	$mobile_servers_d=\@mobile_servers;
	$ctms_servers_d=\@ctms_servers;
	$kavsdk_servers_d=\@kavsdk_servers;
	
	print_geo_servers($dns_servers_d);
	print_geo_servers($geo_servers_d);
	print_geo_servers($mobile_servers_d);
	print_geo_servers($ctms_servers_d);
	print_geo_servers($kavsdk_servers_d);
	
	print_time("[main] print all_dnses_mas count = ".scalar(@all_dnses_mas));
	print_time("[main] print all_dnses = ".$all_dnses);

	open(all_dnses_file,"> ".$all_dnses);	
	@all_dnses_mas_sort=sort(@all_dnses_mas);
	foreach my $dns (@all_dnses_mas_sort)
	{
		chomp $dns;
		print_time("[main] all_dnses_mas dns = ".$dns);	
		print all_dnses_file $dns."\n";
	}
	close(all_dnses_file);	

	print_time("[main] print all_servers_mas count = ".scalar(@all_servers_mas));
	print_time("[main] print all_servers = ".$all_servers);

	open(all_servers_file,"> ".$all_servers);	
	@all_servers_mas_sort=sort(@all_servers_mas);
	foreach my $server (@all_servers_mas_sort)
	{
		chomp $server;
			
		print all_servers_file $server."\n";
		print_time("[main] all_servers_mas server = ".$server);	
	}
	close(all_servers_file);

	print_time("[main] print all_ip count = ".scalar(@all_ip));
	print_time("[main] print all_ip = ".$all_ip);

	open(all_ip_file,"> ".$all_ip);	
	open(table,"> ".$table);	
	open(tabledat,"> ".$tabledat);	
	#open(table_final,"> ".$table_final);	
	@all_ip_mas_sort=sort(@all_ip_mas);
    my @servers_table=();
	my $idx=0;
	
	my $color1="#FFFFFF";
	my $color2="#E0E0E2";
	my $color_key=0;
	$color=$color2;
	my $dnses=getDnses();
	my $services_dns=getServices();
	
	
	foreach my $ip (@all_ip_mas_sort)
	{
		print_time("[main] all_ip_mas_sort ip = ".$ip." processing");			
		chomp $ip;
		my $hips=0;
		my $hipst=0;
		my $url=0;
		my $pbs=0;
		my $p2p=0;
		my $mobile_stat=0;
		my $mobile_file=0;
		
		print_time("[main] all_ip ip = ".$ip);		
		print all_ip_file $ip."\n";
		my $hostname=get_host_name($ip);
		my $dataCenter=getDataCenter($hostname);
		my $dataCenterBasic=cut($dataCenter,"0","-");
		my $dataCenterAdd=cut($dataCenter,"1","-");
		my $countryLetters=returnDataCenter($hostname);
		
		my $result = $dataCenterBasic.";";
		$result = $result.$ip.";";
		$result = $result.$dataCenterAdd.";";
		$result = $result.$countryLetters.";";
		$result = $result.$hostname.";";
		
		foreach my $service (@$services_dns)
		{
			print_time("[main] services_dns countryLetters = ".$countryLetters." service = ".$service." hostname = ".$hostname." processing start");		
			my $service_d=checkService($service.";".$hostname);
			${$countryLetters."_".uc($service)}=${$countryLetters."_".uc($service)}+$service_d;
			$result = $result.$service_d.";";
		}
		push @servers_table, $result."\n";
		print tabledat $result."\n";
		print_time("[main] all_ip ip = ".$ip." hostname = ".$hostname." dataCenter = ".$dataCenter);			
	}
	print_time("[main] result tabledat = ".$result);	
	my @servers_table_sort = sort(@servers_table);
	print table "<html>\n";
	print table "<head>\n";
	print table "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=windows-1251\">\n";
	print table "</head>";
	print table "<style type=\"text/css\"> 
  .dns {
    display: block; /* Строчно-блочный элемент */
    position: relative; /* Относительное позиционирование */
   }
   .dns:hover::after {
	white-space: pre;
	text-align:left;
    content: attr(data-title); /* Выводим текст */
    position: absolute; /* Абсолютное позиционирование */
    left: 10%; top: 10%; /* Положение подсказки */
    z-index: 1; /* Отображаем подсказку поверх других элементов */
    background: rgba(255,255,230,0.9); /* Полупрозрачный цвет фона */
    font-family: Arial, sans-serif; /* Гарнитура шрифта */
    font-size: 15px; /* Размер текста подсказки */
    padding: 5px 10px; /* Поля */
    border: 1px solid #333; /* Параметры рамки */
   }
</style><script type=\"text/javascript\" src=\"krest5.js\"></script>";

	print table "<b>GeoDNS Server Table</b><br><br>";
	print table "<table colspan=11 rowspan=2 border=1>";
	print table "<tr bgcolor=\"#C0C0C6\">";
	#print table "<td><b>Datacenter</b></td>";
	#print table "<td><b>Code</b></td><td><b>Server IP</b></td>";
	#print table "<td><b>Server Name</b></td>";
	#foreach my $service (@$services_dns)
	#{
	#	print_time("[main] services_dns service = ".$service." processing to table");		
	#	print table "<td><b>".$service."</b></td>";
	#}
	#print table "</tr>";

	print_time("[main] servers_table_sort count = ".scalar(@servers_table_sort));	

	foreach my $line (@servers_table_sort)
	{
		chomp $line;
		my $countryLetters_prev;
		print_time("[main] servers_table_sort line = ".$line);		
		my $dataCenterBasic=cut($line,"0",";");
		my $ip=cut($line,"1",";");
		my $dataCenterAdd=cut($line,"2",";");
		my $countryLetters=cut($line,"3",";");
		if ($idx != 0)
		{
			$countryLetters_prev=cut($servers_table_sort[$idx-1],"3",";");
		}
		
		my $hostname=cut($line,"4",";");
		
		
		if (($countryLetters ne $countryLetters_prev) && ($color_key==1))
		{
			$color=$color1;
			$color_key=0;
			print table "<tr bgcolor=\"#C0C0C6\">";
			print table "<td><b>Datacenter</b></td>";
			print table "<td><b>Code</b></td><td><b>Server IP</b></td>";
			print table "<td><b>Server Name</b></td>";
			foreach my $service (@$services_dns)
			{
				print_time("[main] services_dns service = ".$service." processing to table");		
				print table "<td><b>".$service."</b></td>";
			}
			print table "<td><b>Rabbit</b></td></tr>";
			#print table "</tr>";			
		}		
		elsif (($countryLetters ne $countryLetters_prev) && ($color_key==0))
		{
			$color=$color2;
			$color_key=1;
			print table "<tr bgcolor=\"#C0C0C6\">";
			print table "<td><b>Datacenter</b></td>";
			print table "<td><b>Code</b></td><td><b>Server IP</b></td>";
			print table "<td><b>Server Name</b></td>";
			foreach my $service (@$services_dns)
			{
				print_time("[main] services_dns service = ".$service." processing to table");		
				print table "<td><b>".$service."</b></td>";
			}
			print table "<td><b>Rabbit</b></td></tr>";
		}		
		print_time("[main] countryLetters = ".$countryLetters." countryLetters_prev = ".$countryLetters_prev." color = ".$color." color_key ".$color_key);				
		print table "<tr bgcolor=\"".$color."\"><td>\n";
		print table "<b>".$dataCenterBasic."-".$dataCenterAdd."<b></td><td>".$countryLetters."</td>\n";
		print table "<td>".$ip."</td>";
		my $server=getToolTipTdServer($hostname,$hostname);
		print table $server;

		my $index=5;
		foreach my $service (@$services_dns)
		{
			print_time("[main] services_dns service = ".$service." processing to final index = ".$index);		
			my $result;
			$result=getToolTipTd(checknull(cut($line,$index,";")),$hostname,$service);
			print table $result;
			$index++;
		}
		$rabbit_count = get_rabbit_queue_count($hostname);
		print_time("[main] rabbit_count = ".$rabbit_count." server = ".$server);		
		if ($rabbit_count != 0)
		{
			$rabbit=getToolTipTdRabbit($rabbit_count,$hostname);
			print_time("[main] getToolTipTdRabbit rabbit = ".$rabbit);		
			${$countryLetters."_rabbit"}=${$countryLetters."_rabbit"}+$rabbit_count;
		}
		else
		{
			$rabbit="<td></td>";
		}
		print table $rabbit."</tr>";
		$idx++;		
	}
	
	print table "<tr bgcolor=\"#C0C0C6\"><td><b>Datacenter</b></td><td><b>Code</b></td><td><b>Server IP</b></td><td><b>Server Name</b></td>";
	foreach my $service (@$services_dns)
	{
		print_time("[main] services_dns service = ".$service." processing to table");		
		print table "<td><b>".$service."</b></td>";
	}
	print table "<td><b>Rabbit</b></td></tr>";
	
	foreach my $center (@datacenters)
	{
		print_time("[main] datacenters center = ".$center);		
		print table "<tr bgcolor=\"#C0C0C6\">\n";
		print table "<td><b>".returnRusDataCenter($center)."</b></td>\n";
		print table "<td><b>".$center."</b></td>\n";
		print table "<td><b>-----</b></td>\n";
		print table"<td><b>-----</b></td>\n";		

		foreach my $service (@$services_dns)
		{
			print_time("[main] services_dns center ".$center." service = ".$service." processing summ");		
			my $result;
			$result="<td><b>".${$center."_".uc($service)}."</b></td>\n";
			print table $result;
		}

		print table "<td><b>".${$center."_rabbit"}."</b></td></tr>";
	}	
	print table "</table>";
	print table "</html>\n";
	close(table);
	close(tabledat);
	
	close(all_ip_file);
}

sub print_time
{
	$text=shift;
	$tm_now = localtime;
	$datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
}

sub getToolTipTdServer
{
	my $message=shift;
	my $server=shift;
	my $result;
	$result=$result."<td align=\"left\"><div class=\"dns\" data-title=\"".getDnsesByServer($server)."\">".$message."</div></td>";
	print_time("[getToolTipTdServer] message = ".$message);
	print_time("[getToolTipTdServer] server = ".$server);
	print_time("[getToolTipTdServer] service = ".$service);
	print_time("[getToolTipTdServer] result = ".$result);
	return $result;
}
sub getToolTipTdRabbit
{
	my $message=shift;
	my $server=shift;
	my $result;
	$result=$result."<td align=\"center\"><div class=\"dns\" data-title=\"".get_rabbit_queue($server)."\"><b>".$message."</b></div></td>";
	print_time("[getToolTipTdRabbit] message = ".$message);
	print_time("[getToolTipTdRabbit] server = ".$server);
	print_time("[getToolTipTdRabbit] result = ".$result);
	return $result;
}
sub getToolTipTd
{
	my $message=shift;
	my $server=shift;
	my $service=shift;
	my $result;
	$result=$result."<td align=\"center\"><div class=\"dns\" data-title=\"".getDnsesByServerAndService($server,$service)."\"><b>".$message."</b></div></td>";
	print_time("[getToolTipTd] message = ".$message);
	print_time("[getToolTipTd] server = ".$server);
	print_time("[getToolTipTd] service = ".$service);
	print_time("[getToolTipTd] result = ".$result);
	return $result;
}
sub getDnses
{
	my $shell = "cat ".$geo_servers." | cut -f 1 -d \";\" | uniq";
	print_time("[getDnses] shell = ".$shell);
	my @result=`$shell`;
	
	foreach my $dns (@result)
	{
		chomp $dns;
		print_time("[getDnses] dns = ".$dns);
	}
	
	my $result_d=\@result;
	return $result_d;
}
sub getServices
{
	my $shell = "cat ".$geo_servers." | cut -f 2 -d \";\" | sort | uniq";
	print_time("[getServices] shell = ".$shell);
	my @result=`$shell`;
	
	foreach my $service (@result)
	{
		chomp $service;
		print_time("[getServices] service = ".$service);
	}
	
	my $result_d=\@result;
	return $result_d;
}
sub getServicesByDns
{
	my $dns=shift;
	my $shell = "cat ".$geo_servers." | grep ".$dns." | cut -f 2 -d \";\" | sort | uniq";
	print_time("[getServicesByDns] shell = ".$shell);
	my @result=`$shell`;
	
	foreach my $service (@result)
	{
		chomp $service;
		print_time("[getServicesByDns] dns = ".$dns." service = ".$service);
	}
	
	my $result_d=\@result;
	return $result_d;
}
sub getDnsesByServer
{
	my $server=shift;
	my $string=";".$server.";";
	open(geo_servers,$geo_servers);
	my @geo_servers=<geo_servers>;
	my @dnses=grep(/$string/,@geo_servers);
	my $result;
	foreach my $dns_line (@dnses)
	{
		my $dns=cut($dns_line,"4",";");
		my $dns_type=cut($dns_line,"0",";");
		my $service=cut($dns_line,"1",";");
		$result=$result."[".$dns_type."] [".$service."] : ".$dns."\n";
	}
	print_time("[getDnsesByServer] server = ".$server." result = ".$result);
	return $result;
}
sub getDnsesByServerAndService
{
	my $server=shift;
	my $service=shift;
	my $string=$service.";".$server;
	open(geo_servers,$geo_servers);
	my @geo_servers=<geo_servers>;
	my @dnses=grep(/$string/,@geo_servers);
	my $result;
	foreach my $dns_line (@dnses)
	{
		my $dns=cut($dns_line,"4",";");
		my $dns_type=cut($dns_line,"0",";");
		$result=$result."[".$dns_type."] : ".$dns."\n";
		print_time("[getDnsesByServerAndService] result = ".$result);
	}
	print_time("[getDnsesByServerAndService] server = ".$server." service = ".$service." result = ".$result);
	return $result;
}
sub checknull
{
	my $value=shift;
	if ($value == 0)
	{
		$value="";
	}
	return $value;
}
sub print_geo_servers
{
	my $dns_servers=shift;
	open(geo_servers,">> ".$geo_servers);
	@dns_servers_sort = sort (@$dns_servers);
	foreach my $server (@dns_servers_sort)
	{
		chomp $server;
		print geo_servers $server."\n";
	}		
	close(geo_servers);
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
		print_time("info line = ".$line);
	}
	print geo2ip_convert "------------\n";
	@p4syncres=`/usr/local/bin/p4 sync -f`;
	print geo2ip_convert "P4 sync result:<br>\n";
	print geo2ip_convert "------------<br>\n";
	foreach $line (@p4syncres)
	{
		chomp($line);
		print geo2ip_convert $line."<br>\n";
		print_time("[process_perforce] sync line = ".$line);	
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
		print_time("[process_perforce] Syc OK");
	}
	close(geo2ip_convert);
	
	print_time("------------");
	$geo_perforce_path=seach_params2('/export/parameters.dat','geo_perforce_path');
	print_time("geo_perforce_path = ".$geo_perforce_path);

	opendir(geo_perforce_dir, $geo_perforce_path);
	@geo_perforce_files_all= readdir(geo_perforce_dir); 
	@geo_perforce_files=grep(/yaml/,@geo_perforce_files_all);
	$dns_csn_allservers=$geo_files."/allservers.dat";
	$geo_servers=$geo_servers_path."/geo_servers.dat";
	$all_servers=$all_servers_path."/all_servers.dat";
	
	print_time("dns_csn_allservers = ".$dns_csn_allservers);			
	print_time("geo_services = ".$geo_services);			
	print_time("geo_servers = ".$geo_servers);			
	print_time("all_servers = ".$all_servers);			
	
	unlink($dns_csn_allservers);
	#unlink($geo_servers);
	#unlink($all_servers);
		
	@csn_allservers=();
	my @all_services_mas=();
	@geo_services_mas=();
	
	unlink($geo_services);
	print_time("start processing normal servers");
	foreach $geofile (@geo_perforce_files)
	{
		chomp($geofile);
		print_time("converting file ".$geofile);
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
	print_time("geo_services_mas count =".scalar(@geo_services_mas));
	print_time("end processing normal servers");

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
	print_time("[delete_tmp_files] dir = ".$dir);
	print_time("[delete_tmp_files] files = ".$files);
	opendir(DIR, $dir);
	my @FILES= readdir(DIR); 
	print_time("[delete_tmp_files] count files = ".scalar(@FILES));
	my @files_for_delete=grep(/$files/,@FILES);
	foreach my $file (@files_for_delete)
	{
		print_time("[delete_tmp_files] file = ".$dir."/".$file);	
		unlink($dir."/".$file);
	}
}

sub custom_services_get
{
	opendir(geo_dns_services_dir, $geo_dns);
	print_time("geo_dns_services = ".$geo_dns);	
	my @geo_dns_services_files_all= readdir(geo_dns_services_dir); 
	my @geo_dns_services_file_dat=grep(/ser/,@geo_dns_services_files_all);
	print_time("count geo_dns_services_files_all = ".scalar(@geo_dns_services_files_all));
	print_time("count geo_dns_services_file_dat = ".scalar(@geo_dns_services_file_dat));	
	my @custom_services=();
	my $i=0;	
	foreach my $file (@geo_dns_services_file_dat)
	{
		print_time("[custom_services] ".$file);
		open(file,$geo_dns."/".$file);
		my @file=<file>;
		$file_service=cut($file,"1",".");
		foreach my $line (@file)
		{
			chomp $line;
			print_time("[custom_services] file = ".$file." file_service = ".$file_service." line = ".$line);			
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
	my $all_ip_mas=shift;
	
	opendir(geo_dns_dir, $dir);
	print_time("[custom_servers_get] dir = ".$dir);
	print_time("[custom_servers_get] type = ".$type);
	
	my @geo_dns_files_all= readdir(geo_dns_dir); 
	my @geo_dns_file_dat=grep(/dat/,@geo_dns_files_all);
	print_time("[custom_servers_get] count geo_dns_files_all = ".scalar(@geo_dns_files_all));
	print_time("[custom_servers_get] count geo_dns_file_dat = ".scalar(@geo_dns_file_dat));
	#my @custom_servers=();
	#my $i=0;
	foreach my $file (@geo_dns_file_dat)
	{
		print_time("[custom_servers_get] file = ".$file);
		open(file,$dir."/".$file);
		my @file=<file>;
		foreach my $dns (@file)
		{
			chomp $dns;
			print_time("[custom_servers_get] dns from file = ".$dns);
			@addresses = gethostbyname($dns);
			#my ($name,$aliases,$addrtype,$length,@addresses) = gethostbyname($dns);
			
			$shell_aliases="host ".$dns." | grep alias | cut -f 6 -d ' '";
			print_time("[custom_servers_get] shell_aliases = ".$shell_aliases);
			my $aliases;
			my @res_aliases=`$shell_aliases`;
			foreach my $alias (@res_aliases)
			{
				chomp $alias;
				$aliases=$aliases.$alias." ";
			}
			
			@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
			print_time("[custom_servers_get] aliases = ".$aliases." file = ".$file." dns = ".$dns);
			#my @aliases_mas=split(" ", $aliases);
			foreach my $alias (@res_aliases)
			{
				print_time("[custom_servers_get] alias = ".$alias." file = ".$file." dns = ".$dns);
			}			
			if ($aliases eq "")
			{
				$aliases="none";
			}
			$dnspush=$dns.";".$type.";".$aliases;
			if (!grep(/$dnspush/,@all_dnses_mas))
			{
				push @all_dnses_mas, $dnspush;
			}			
			foreach my $ip (@addresses)
			{
				chomp $ip;
				my $host = get_host_name($ip);
				my $service_name=cut($file,"0",".");
				print_time("[custom_servers_get] type = ".$type." service_name = ".$service_name." file = ".$file." host = ".$host." ip = ".$ip." dns = ".$dns);
				push @servers, $type.";".$service_name.";".$host.";".$ip.";".$dns.";\n";
				if (!grep(/$host/,@all_servers_mas))
				{
					push @all_servers_mas, $host;
				}
				if (!grep(/$ip/,@$all_ip_mas))
				{
					if ($ip ne "")
					{				
						push @$all_ip_mas, $ip;
					}
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
	print_time("[getip] host = ".$host);
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
	print_time("dir = ".$dir);
	my @geo_dns_files_all= readdir(geo_dns_dir); 
	my @geo_dns_file_dat=grep(/dat/,@geo_dns_files_all);
	print_time("[process_custom_servers] count geo_dns_files_all = ".scalar(@geo_dns_files_all));
	print_time("[process_custom_servers] count geo_dns_file_dat = ".scalar(@geo_dns_file_dat));

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
		
		print_time("[process_custom_servers] type = ".$type." service_name = ".$service_name." host = ".$host." ip = ".$ip." dns = ".$dns);
		print_custom_file($servers[$i][0],"<tr><td>".$servers[$i][1]."</td><td>".$servers[$i][2]."</td><td>".$servers[$i][3]."</td></tr>",$type);
		$i++;
	}
	foreach my $file (@geo_dns_file_dat)
	{
		print_custom_file($file,"</table></html>",$type);
	}
}
sub create_host_names
{
	print_time("[create_host_names] start");
	use Socket;
	open(servers_hosts, "> /export/geo/servers_hosts.dat");
	opendir(dir, "/export/controller/servers_hosts");
	my @dir_files_all= readdir(dir); 
	my @dir_files=grep(/dat/,@dir_files_all);
	#print_time("[create_host_names] foreach");
	print_time("[create_host_names] dir_files_all count = ".scalar(@dir_files_all));						
	print_time("[create_host_names] dir_files count = ".scalar(@dir_files));						
	my $found_code=0;
	my $ip;
	foreach my $file (@dir_files)
	{
		open(file,"/export/controller/servers_hosts/".$file);
		my @file=<file>;
		foreach my $line (@file)
		{
			chomp($line);
			my $name=cut(cut($line,"0","\r"),"0",";");
		
			#(my $hostname, my $aliases, my $addrtype, my $length, my @addresses) = gethostbyname $name;
			my @addresses = gethostbyname($name);
			@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
			#@addresses = map { inet_ntoa(inet_aton($name)) } @addresses[4..$#addresses];
			#print_time("ipn = ".$ipn);
			print_time("[create_host_names] line = ".cut($line,"0","\r")." name = ".$name." addresses count = ".scalar(@addresses)." ip = ".$addresses[0]);				
			my $ip_f;
			if ($addresses[0] eq "")
			{
				$ip_f="none";
			}
			else
			{
				$ip_f=$addresses[0];
			}
			print servers_hosts $ip_f."=".$name."\n";
		}
		close(file);
	}
	close(servers_hosts);
	closedir(dir);
	return $found;
}
sub get_host_name
{
	my $ip=shift;
	my $found=seach_params2('/export/geo/servers_hosts.dat',$ip);
	
	if ($found eq "")
	{
		#my $get_host_name_logview="/export/controller/controller.gethostname_logview.pl ".$ip;
		#my @res=`$get_host_name_logview`;
		#my $hostname=$res[0];
		my $shellid='id';
		my @resid=`$shellid`;
		foreach my $line (@resid)
		{
			chomp $line;
			print_time("[get_host_name][not_found_hostname][".$ip."] shell resid line = ".$line);				
		}
		
		my $shell='ssh -i /export/keys/fe-0/id_rsa -o StrictHostKeyChecking=no logview@'.$ip.' "hostname" 2>&1 | grep -v Warning | grep -v Could';
		print_time("[get_host_name][not_found_hostname][".$ip."] ip = ".$ip);	
		print_time("[get_host_name][not_found_hostname][".$ip."] shell = ".$shell);	
		my @res=`$shell`;
		open (filedat_read,"/export/controller/servers_hosts/other.dat");
		@file=<filedat_read>;
		my $hostname;
		foreach my $line (@res)
		{
			chomp $line;
			print_time("[get_host_name][not_found_hostname][".$ip."] res line = ".$line);	
			if (grep(/denied/,@file))
			{
				print_time("[get_host_name][not_found_hostname][".$ip."] denied");	
				$hostname="host_".$ip;				
			}
			elsif (!grep(/$line/,@file))
			{
				open (filedat_write,">> /export/controller/servers_hosts/other.dat");
				print filedat_write $line."\n";		
				$hostname=$line;
				print_time("[get_host_name][not_found_hostname][".$ip."] res hostname = ".$hostname);
				close (filedat_write);
			}
			else
			{
				#print "host_".$ip;
				$hostname="host_".$ip;
			}
		}		
		
		$found=$hostname;
		print_time("[get_host_name][not_found_hostname][".$ip."] hostname = ".$hostname);		
	}	
	
	print_time("[get_host_name] ip = ".$ip." name = ".$found);
	return $found;
}
sub get_host_name2
{
	print_time("[get_host_name] start");
	my $ip=shift;
	#print_time("[get_host_name] ip = ".$ip);
	my $found;
	opendir(dir, "/export/controller/servers_hosts");
	my @dir_files_all= readdir(dir); 
	my @dir_files=grep(/dat/,@dir_files_all);
	#print_time("[get_host_name] foreach");
	print_time("[get_host_name] dir_files_all count = ".scalar(@dir_files_all));						
	print_time("[get_host_name] dir_files count = ".scalar(@dir_files));						
	my $found_code=0;
	foreach my $file (@dir_files)
	{
		open(file,"/export/controller/servers_hosts/".$file);
		my @file=<file>;
		foreach my $line (@file)
		{
			chomp($line);
			#print_time("[get_host_name] line = ".$line);
			my $name=cut($line,"0",";");
			my @addresses = gethostbyname($name);
			@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
			if ($addresses[0] eq $ip)
			{
				$found=$name;
				print_time("[get_host_name][found_hostname][".$ip."] name = ".$name." file = ".$file." found_code = ".$found_code);
				$found_code=1;
				last;
			}
			else
			{
				print_time("[get_host_name][found_hostname][".$ip."] name = ".$name." file = ".$file." found_code = ".$found_code);					
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
		#my $get_host_name_logview="/export/controller/controller.gethostname_logview.pl ".$ip;
		#my @res=`$get_host_name_logview`;
		#my $hostname=$res[0];
		my $shellid='id';
		my @resid=`$shellid`;
		foreach my $line (@resid)
		{
			chomp $line;
			print_time("[get_host_name][not_found_hostname][".$ip."] shell resid line = ".$line);				
		}
		
		my $shell='ssh -i /export/keys/fe-0/id_rsa -o StrictHostKeyChecking=no logview@'.$ip.' "hostname" 2>&1 | grep -v Warning';
		print_time("[get_host_name][not_found_hostname][".$ip."] ip = ".$ip);	
		print_time("[get_host_name][not_found_hostname][".$ip."] shell = ".$shell);	
		my @res=`$shell`;
		open (filedat_read,"/export/controller/servers_hosts/other.dat");
		@file=<filedat_read>;
		my $hostname;
		foreach my $line (@res)
		{
			chomp $line;
			print_time("[get_host_name][not_found_hostname][".$ip."] res line = ".$line);	
			if (grep(/denied/,@file))
			{
				print_time("[get_host_name][not_found_hostname][".$ip."] denied");	
				$hostname="host_".$ip;				
			}
			elsif (!grep(/$line/,@file))
			{
				open (filedat_write,">> /export/controller/servers_hosts/other.dat");
				print filedat_write $line."\n";		
				$hostname=$line;
				print_time("[get_host_name][not_found_hostname][".$ip."] res hostname = ".$hostname);
				close (filedat_write);
			}
			else
			{
				#print "host_".$ip;
				$hostname="host_".$ip;
			}
		}		
		
		$found=$hostname;
		print_time("[get_host_name][not_found_hostname][".$ip."] hostname = ".$hostname);		
	}
	print_time("[get_host_name] found = ".$found);
	#print_time("[get_host_name] end");
	closedir(dir);
	return $found;
}
sub convert_file
{
	$geo_files=shift;
	$file=shift;
	*csn_allservers=shift;
	*geo_services_mas=shift;
	
	print_time("[convert_file] dns_csn_allservers = ".$dns_csn_allservers);				
	open(file,$file);
	my @file=<file>;
	my @servers=();
	my @custom_service=();
	foreach $line (@file)
	{
		chomp($line);
		if ($line=~m/#/)
		{
			print_time("# detected line = ".$line);		
			next;
		}
		if ($line=~m/    -/)
		{
			#print_time("line = ".$line);
			$server=cut(cut($line,"5"," "),"0",":");
			#print_time("server = ".$server);
			if (grep(/$server/,@servers))
			{
				#print_time("server ".$server." exist");
			}
			else
			{
				#print_time("server ".$server." not exist");
				push (@servers,$server);
			}
		}
	}
	$file_rev=reverse $file;
	#print_time("file_rev = ".$file_rev);
	$file_geo_rev=cut($file_rev,"0","/");
	#print_time("file_geo_rev = ".$file_geo_rev);
	$file_geo=reverse $file_geo_rev;
	#print_time("file_geo = ".$file_geo);
	$service=cut($file_geo,"0",".");
	@servers_sort=sort(@servers);
	print_time("[convert_file] servers count = ".scalar(@servers));
	chomp ($service);
	print_time("service = ".$service);
	open(out,"> ".$geo_files."/".$service.".dat");
	
	my $len_line=length($service);
	my $service_name=substr($service,8,$len_line);

	print_time("service_name = ".$service_name);
	

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
		print_time("[convert_file] server = ".$server." host = ".$host." ip = ".$ip);
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
	unlink($geo_path_url);
	$shell_wget="/usr/local/bin/wget -P ".$geo_path_url." ".$geo_url." 2>&1";
	print_time("[download_dns_conf] shell_wget = ".$shell_wget);
	print_time("[download_dns_conf] check path = ".$geo_path_file);
	
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
			print_time("[download_dns_conf] wget line = ".$line);
		}	
		return 0;
	}
}

sub convert_dns_file
{
	*services=shift;
	*all_servers_mas=shift;	
	*all_dnses_mas=shift;
	my $all_ip_mas=shift;
	
	open(fileconf,$geo_path_file);
	my @fileconf=<fileconf>;
	my @services_full=grep(/name /,@fileconf);
	print_time("[convert_dns_file] count services_full = ".scalar(@services_full));
	print_time("[convert_dns_file] geo_path_file = ".$geo_path_file);

	foreach my $services_full_line (@services_full)
	{
		chomp $services_full_line;		
		print_time("[convert_dns_file] services_full_line = ".$services_full_line);
		$services_full_line =~ s/^\s+//;  
		print_time("[convert_dns_file] services_full_line = ".$services_full_line);
		#my $service=cut(cut(cut($services_full_line,"5"," "),"0","."),"1","-");
		my $service=cut(cut(cut($services_full_line,"1"," "),"0","."),"1","-");
		print_time("[convert_dns_file] service = ".$service);
		unlink ($geo_geo."/".$service.".dat");
	}

	print_time("[convert_dns_file] count services = ".scalar(@services));

	foreach my $service (@services)
	{
		print_time("[convert_dns_file] service = ".$service);
	}
	
	#foreach my $line (@fileconf)
	for (my $i=0; $i<=scalar(@fileconf); $i++)
	{
		my $line;
		$line=$fileconf[$i];
		chomp $line;
		#print_time("[convert_dns_file] line = ".$line);
		if (grep (/define service/, $line))
		{
			print_time("[convert_dns_file] found define service = ".$line);
			$i++;
			$line=$fileconf[$i];
			if (grep (/name /, $line))
			{
				#$service_name=~s/\s//g;
				$line =~ s/^\s+//; 				
				$service_name=cut(cut(cut($line,"1"," "),"0","."),"1","-");
				$dns_name=cut(cut($line,"1"," "),"0",".");
				print_time("[convert_dns_file] service_name = ".$service_name);
				print_time("[convert_dns_file] dns_name = ".$dns_name);
			}
		}
		elsif (grep (/host/, $line))
		{
			$line =~ s/^\s+//;  
			my $host=cut(cut($line,"1"," "),"1","=");
			my $ip=getip($host);
			my $dns=$dns_name."-geo.company.com";
			
			print_time("[convert_dns_file] host = ".$host." service_name = ".$service_name);
			my $line="geo;".$service_name.";".$host.";".$ip.";".$dns;
			print_time("[convert_dns_file] line = ".$line);
			if (!grep (/$line/,@services))
			{
				
				#my $dns="csn-".$service_name."-geo.company.com";
				
				#my @addresses = gethostbyname($dns);
				#@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];				
				print_time("[convert_dns_file] push = geo;".$service_name.";".$host.";".$ip.";".$dns.";");
				push @services, "geo;".$service_name.";".$host.";".$ip.";".$dns.";\n";
				#my $adresses=sub_get_ip_fromt_dns($dns);
				#print_time("[convert_dns_file] service_name = ".$service_name." adresses count = ".scalar(@$adresses));
				#foreach my $ip (@$adresses)
				#{
				#	print_time("[convert_dns_file] push = geo;".$service_name.";".$host.";".$ip.";".$dns.";");	
				#	push @services, "geo;".$service_name.";".$host.";".$ip.";".$dns.";resolv;\n";
				#}
				if (!grep(/$host/,@all_servers_mas))
				{
					push @all_servers_mas, $host;
				}				
				$shell_aliases="host ".$dns." | grep alias | cut -f 6 -d ' '";
				#print_time("[convert_dns_file] service_name = ".$service_name." shell_aliases = ".$shell_aliases);
				my $aliases;
				my @res_aliases=`$shell_aliases`;				
				foreach my $alias (@res_aliases)
				{
					chomp $alias;
					$aliases=$aliases.$alias." ";
				}				
				if ($aliases eq "")
				{
					$aliases="none";
				}				
				$dnspush=$dns.";geo;".$aliases;
				print_time("[convert_dns_file] service_name = ".$service_name." dnspush = ".$dnspush);
				if (!grep(/$dnspush/,@all_dnses_mas))
				{
					push @all_dnses_mas, $dnspush;
				}					
				if (!grep(/$ip/,@$all_ip_mas))
				{
					if ($ip ne "")
					{
						push @$all_ip_mas, $ip;
					}
				}					
			}
			else
			{
				#print_time("exist host = ".$host." service_name = ".$service_name);
			}
		}
		else
		{
			next;
		}
	}
	print_time("[convert_dns_file] count services ".scalar(@services));
	foreach my $service (@services)
	{
		chomp $service;
		print_time("[convert_dns_file] services service = ".$service);	
	}
	
	foreach my $service_line (@services)
	{
		chomp $service_line;
		#print_time("[convert_dns_file] service_line ".$service_line);
		my $service_name=cut($service_line,"1",";");
		open (file, ">> ".$geo_geo."/".$service_name.".dat");
		my $type=cut($service_line,"0",";");
		my $host=cut($service_line,"2",";");
		my $ip=cut($service_line,"3",";");
		my $geodns=cut($service_line,"4",";");
		print_time("[convert_dns_file] massive type = ".$type." service_name = ".$service_name." host = ".$host." ip = ".$ip." geodns = ".$geodns);
		print file $service_line."\n";
		close(file);
	}
	close(fileconf);
}
sub sub_get_ip_fromt_dns
{
	my $source_dns=shift;
	print_time("[sub_get_ip_fromt_dns] source_dns = ".$source_dns);
	my @addresses = gethostbyname($source_dns);
	@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];	
	foreach my $dns (@addresses)
	{
		print_time("[sub_get_ip_fromt_dns] source_dns = ".$source_dns." dns = ".$dns);
	}
	return \@addresses;
}
sub geo_check
{
	my $server=shift;
	my @result=();
	print_time("[geo_check] server = ".$server);
	my  $geo_files_dir=seach_params2('/export/parameters.dat','geo_files');
	#print_time("geo_files_dir = ".$geo_files_dir);
	opendir(geo_files_dir, $geo_files_dir);
	my @geo_files_all= readdir(geo_files_dir); 
	#print_time("geo_files_all count = ".scalar(@geo_files_all));
	my  @geo_files=grep(/dns-csn/,@geo_files_all);
	#print_time("geo_files count = ".scalar(@geo_files));
	my $geofile;
	foreach $geofile (@geo_files)
	{
		chomp ($geofile);
		open(file,$geo_files_dir."/".$geofile);
		my @file=<file>;
		if (grep(/$server/,@file))
		{
			print_time("[geo_check] server = ".$server." geofile = ".$geofile);
			push @result, $geofile;
		}
		close(file);
	}
	return @result;
}
sub returnDataCenter
{
	my $server=shift;
	my $country;
	my $cuntry_letters;
	
	if (grep(/-bjg-/,$server))
	{
		$country="Пекин";
		$cuntry_letters="bjg";
	}
	elsif (grep(/-hkg-/,$server))
	{
		$country="Гонконг";
		$cuntry_letters="hkg";
	}		
	elsif (grep(/-trt-/,$server))
	{
		$country="Торонто";
		$cuntry_letters="trt";
	}		
	elsif (grep(/-msk-/,$server))
	{
		$country="Москва";
		$cuntry_letters="msk";
	}	
	elsif (grep(/-fft-/,$server))
	{
		if (grep(/-fft-st2-/,$server))
		{
			$country="Франкфурт2";
			$cuntry_letters="fft2";
		}	
		elsif (grep(/-fft-fe6-/,$server))
		{
			$country="Франкфурт2";
			$cuntry_letters="fft2";
		}
		elsif (grep(/-fft-fe7-/,$server))
		{
			$country="Франкфурт2";
			$cuntry_letters="fft2";
		}		
		else
		{
			$country="Франкфурт";
			$cuntry_letters="fft";
		}
	}	

	print_time("[returnDataCenter] server = ".$server." country = ".$country." country_letters = ".$cuntry_letters);
	return $cuntry_letters;
}
sub returnRusDataCenter
{
	my $cuntry_letters=shift;
	my $country;
	
	if ($cuntry_letters eq "bjg")
	{
		$country="Пекин";
	}
	elsif ($cuntry_letters eq "hkg")
	{
		$country="Гонконг";
	}		
	elsif ($cuntry_letters eq "trt")
	{
		$country="Торонто";
	}		
	elsif ($cuntry_letters eq "msk")
	{
		$country="Москва";
	}	
	elsif ($cuntry_letters eq "fft2")
	{
		$country="Франкфурт2";
	}	
	elsif ($cuntry_letters eq "fft")
	{
		$country="Франкфурт";
	}
	print_time("[returnRusDataCenter] cuntry_letters = ".$cuntry_letters." country = ".$country);
	return $country;
}
sub checkService
{
	my $check=shift;
	my $result=0;
	
	open(geo_servers,$geo_servers);
	my @geo_servers=<geo_servers>;
	if (grep(/$check/,@geo_servers))
	{
		$result=1;
	}
	print_time("[checkService] check = ".$check." result = ".$result);
	return $result;
}
sub getStCenter
{
	my $server=shift;
	my $result;
	if (grep(/-st-/,$server) || grep(/-st1-/,$server) || grep(/-st2-/,$server) || grep(/-st3-/,$server))
	{
		$result=1;
	}
	else
	{
		$result=0;
	}
	print_time("[getStCenter] server = ".$server." result = ".$result);
	return $result;
}

sub getDataCenter
{

	my $server=shift;
	my $result="none";
	my $country;
	my $country_letters;
	my @datacenters=("msk","fft","bjg","hkg","trt");

	foreach my $datacenter (@datacenters)
	{
		if (grep(/-bjg-/,$server))
		{
			$country="Пекин";
			$country_letters="bjg";
		}
		elsif (grep(/-hkg-/,$server))
		{
			$country="Гонконг";
			$country_letters="hkg";
		}		
		elsif (grep(/-trt-/,$server))
		{
			$country="Торонто";
			$country_letters="trt";
		}		
		elsif (grep(/-msk-/,$server))
		{
			$country="Москва";
			$country_letters="msk";
		}	
		elsif (grep(/-fft-st2-/,$server))
		{
			$country="Франкфурт2";
			$country_letters="fft";
		}	
		elsif (grep(/-fft-fe6-/,$server))
		{
			$country="Франкфурт2";
			$country_letters="fft";
		}
		elsif (grep(/-fft-fe7-/,$server))
		{
			$country="Франкфурт2";
			$country_letters="fft";
		}		
		elsif (grep(/-fft-/,$server))
		{
			$country="Франкфурт";
			$country_letters="fft";
		}			
	
		my $rs="rs-".$country_letters."-fe-";
		my $fe="csn-".$country_letters."-fe-";
		my $fe2="csn-".$country_letters."-fe2-";
		my $fe3="csn-".$country_letters."-fe3-";
		my $st="csn-".$country_letters."-st-";
		my $st2="csn-".$country_letters."-st2-";
		my $st3="csn-".$country_letters."-st3-";
		my $u4="csn-".$country_letters."-fe4-";
		my $u5="csn-".$country_letters."-fe5-";
		my $fe6="csn-".$country_letters."-fe6-";
		my $fe7="csn-".$country_letters."-fe7-";
		my $fe8="csn-".$country_letters."-fe8-";
		my $ipm="csn-".$country_letters."-ipm-";
		
		if (grep(/$rs/,$server))
		{
			$result=$country."-RS";	
		}
		elsif (grep(/$fe/,$server))
		{
			$result=$country."-FE";	
		}
		elsif (grep(/$st/,$server))
		{
			$result=$country."-ST";	
		}
		elsif (grep(/$st2/,$server))
		{
			$result=$country."-ST2";	
		}	
		elsif (grep(/$st3/,$server))
		{
			$result=$country."-ST2";	
		}			
		elsif (grep(/$fe2/,$server))
		{
			$result=$country."-FE2";	
		}
		elsif (grep(/$fe3/,$server))
		{
			$result=$country."-FE3";	
		}		
		elsif (grep(/$u4/,$server) || grep(/$u5/,$server))
		{
			$result=$country."-U";	
		}
		elsif (grep(/$fe6/,$server))
		{
			$result=$country."-FE6";	
		}		
		elsif (grep(/$fe7/,$server))
		{
			$result=$country."-FE7";	
		}		
		elsif (grep(/$fe8/,$server))
		{
			$result=$country."-FE8";	
		}		
		elsif (grep(/$ipm/,$server))
		{
			$result=$country."-IPM";	
		}

	}
	print_time("[getdatacenter] server = ".$server." ip = ".$ip." result = ".$result);	
	return $result;
}
sub get_rabbit_queue_count
{
	my $server=shift;
	open(table_rabbit,$table_rabbit);
	my @table_rabbit=<table_rabbit>;
	#foreach my $line (@table_rabbit)
	#{
	#	chomp $line;
	#	print_time("line = ".$line);
	#}
	my @result_mas = grep(/$server/,@table_rabbit);
	my $result;
	$result=scalar(@result_mas);
	print_time("[get_rabbit_queue_count] result = ".$result." server = ".$server);
	return $result;
	close(table_rabbit)
}
sub get_rabbit_queue
{
	my $server=shift;
	open(table_rabbit,$table_rabbit);
	my @table_rabbit=<table_rabbit>;
	
	my @result_mas = grep(/$server/,@table_rabbit);
	my $result;
	foreach my $line (@result_mas)
	{
		chomp $line;
		my $queue=cut($line,"2",";");
		$result=$result.$queue."\n";
	}
	
	print_time("[get_rabbit_queue] result = ".$result." server = ".$server);
	return $result;
	close(table_rabbit)
}
sub create_rabbbit_file
{
	open(table_rabbit,"> ".$table_rabbit);
	my $browser = LWP::UserAgent->new;
	my $req = HTTP::Request->new(GET => 'http://csn-backend-6.avp.ru:15672/api/queues');
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
		#print_time("line = ".$line->{"name"});
		#print_time("queue = ".$queue." service = ".$service." server = ".$server);
		print table_rabbit $server.".company.com;".$service.";".$queue.";\n";
	}
	close(table_rabbit);
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
	print_time("[seach_params2] file = ".$file);
	print_time("[seach_params2] param = ".$param);
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
	print_time("[seach_params2] parameter = ".$parameter);	
return $parameter;
}
sub process_dat_files
{
	opendir(files, $path."/results");
	@results = readdir(RESULTS); 
}