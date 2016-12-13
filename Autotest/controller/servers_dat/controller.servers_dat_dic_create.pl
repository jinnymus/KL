#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use Switch;
use Socket;

$workpath=shift;
$service=shift;
$dnstype=shift;
$serversdat=shift;
$serversadd=shift;
$serversdic=shift;
$hostsdic=shift;
$listtype=shift;


unlink ($workpath."/".$service."_serversdat.log");

print_time("workpath = ".$workpath);
print_time("service = ".$service);
print_time("dnstype = ".$dnstype);
print_time("serversdat = ".$serversdat);
print_time("serversadd = ".$serversadd);
print_time("serversdic = ".$serversdic);
print_time("hostsdic = ".$hostsdic);
print_time("listtype = ".$listtype);

$geo_files_path=seach_params2("/export/parameters.dat","geo_geo");
$geo_files_path=seach_params2("/export/parameters.dat","geo_servers");

#$geofile=$geo_files_path."/dns-csn-".$service.".dat";
#$geofile=$geo_files_path."/".$service.".dat";
$geofile=$geo_files_path."/geo_servers.dat";

print_time("geo_files_path = ".$geo_files_path);
print_time("geofile = ".$geofile);
print_time("unlink files");

unlink($workpath."/".$serversdat);
unlink($workpath."/".$serversdic);
unlink($workpath."/".$hostsdic);
unlink($workpath."/allhostsdic.dat");

if ($dnstype eq "all")
{
	print_time("call print_adresses dns all");
	$allhostsdat_path=seach_params2("/export/parameters.dat","allhostsdat_path");	
	print_time("allhostsdat_path = ".$allhostsdat_path);
	$allhostsdat_file=$allhostsdat_path."/".$service."_servers_hosts.dat";
	print_time("allhostsdat_file = ".$allhostsdat_file);
	print_time("call print_adresses allhostsdic.dat");
	print_time("listtype = ".$listtype);
	if ($listtype eq "geo")
	{
		print_adresses($workpath, $serversdat, $serversdic, "allhostsdic.dat", $allhostsdat_file, "all", $dnstype, $service);
		print_time("call print_adresses hostsdic.dat");
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $geofile, "product", $dnstype, $service);
	}
	elsif (($listtype eq "") || ($listtype eq "all"))
	{
		print_time("call print_adresses hostsdic.dat empty or all");
		print_adresses($workpath, $serversdat, $serversdic, "allhostsdic.dat", $allhostsdat_file, "all", $dnstype, $service);
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $geofile, "product", $dnstype, $service);
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $workpath."/".$serversadd, "add", $dnstype, $service);
	}
	elsif ($listtype eq "add")
	{
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $workpath."/".$serversadd, "add", $dnstype, $service);
	}
}
else
{
	if ($listtype eq "geo")
	{
		print_time("call print_adresses product");
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $geofile, "product", $dnstype, $service);		
	}
	elsif (($listtype eq "") || ($listtype eq "all"))
	{
		print_time("call print_adresses product");
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $geofile, "product", $dnstype, $service);
		print_time("call print_adresses add");
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $workpath."/".$serversadd, "add", $dnstype, $service);
	}
	elsif ($listtype eq "add")
	{
		print_adresses($workpath, $serversdat, $serversdic, $hostsdic, $workpath."/".$serversadd, "add", $dnstype, $service);
	}	
}


print_time("done");

sub print_adresses
{
	my $workpath=shift;
	my $serversdat=shift;
	my $serversdic=shift;
	my $hostsdic=shift;
	my $serverfilepath=shift;	
	my $type=shift;
	my $dnstype=shift;	
	my $service=shift;
	
	print_time("[print_adresses] ============================================");
	print_time("[print_adresses] type = ".$type);
	print_time("[print_adresses] dnstype = ".$dnstype);
	print_time("[print_adresses] hostsdic = ".$hostsdic);
	print_time("[print_adresses] serverfilepath = ".$serverfilepath);	
	print_time("[print_adresses] service = ".$service);		
	@addreses=();
	if (-e $serverfilepath)
	{
		open(serverfile,$serverfilepath);
		@addreses_unsort=<serverfile>;
		@addreses_all=sort(@addreses_unsort);
		print_time("[print_adresses] addreses count = ".scalar(@addreses_all)." addreses file = ".$serverfilepath);
		if ($type eq "product")
		{
			if ($dnstype eq "all")
			{
				$service_search=";".$service.";";
			}
			else
			{
				$service_search=$dnstype.";".$service.";";
			}
			print_time("[print_adresses] service_search = ".$service_search);
			@addreses_service=grep(/$service_search/,@addreses_all);
			foreach my $serviceline (@addreses_service)
			{
				print_time("[print_adresses] serviceline = ".$serviceline);
				my $address = cut($serviceline,"2",";");
				print_time("[print_adresses] address = ".$address);
				push @addreses, $address;
			}
			#$addr=cut($addre,"0",";");
		}
		elsif ($type eq "add" || $type eq "all" )
		{
			@addreses=@addreses_all;
		}
		foreach my $addrel (@addreses)
		{
			#chomp $addre;
			chomp ($addrel);
			my $addre;
			if ($hostsdic eq "allhostsdic.dat")
			{
				my $len=length($addrel);
				#print_time("len = ".$len);
				$addre=substr($addrel,0,$len-1);
				$addre=$addrel;
			}
			else
			{
				$addre=$addrel;
			}
			
			$addr=cut($addre,"0",";");
			chomp $addr;
			chomp ($addr);
			print_time("addrel = ".$addrel." addre = ".$addre." addr = ".$addr." type = ".$type);
			if ($addr ne "")
			{
				@addresses=();
				print_time("gethostbyname addr = ".$addr);
				@addresses = gethostbyname($addr);
				@addresses = map { inet_ntoa($_) } @addresses[4..$#addresses];
				#$ip=cut($host_info,"3"," ");
				$ip=$addresses[0];
				foreach $adr (@addresses)
				{
					chomp $adr;
					if ($adr eq "")
					{
						$adr="null";
					}
					print_time("adr = ".$adr);
					$parameter="";
					if ( -e $workpath."/".$serversdat)
					{
						$check_ip=seach_string($workpath."/".$serversdat,$adr);
					}
					else
					{
						$check_ip="no";
					}
					if ($check_ip eq "yes")
					{
						print_time("already exist");
					}
					else
					{
						print_time("not exist -> hostsdic file ".$workpath."/".$hostsdic." type ".$type);						
						open (hostsdic,">> ".$workpath."/".$hostsdic);
						print hostsdic $adr."=".$addr."\n";
						close(hostsdic);
						if ($type ne "all")
						{
							print_time("type ".$type);
							if ($dnstype eq "all")
							{
								$addr=seach_params2($workpath."/allhostsdic.dat",$adr);
								#$addr=seach_params2("/export/controller/servers_hosts/".$service."_servers_hosts.dat",$adr);
								chomp ($addr);
							}
							open(serversdat,">> ".$workpath."/".$serversdat);
							open (serversdic, ">> ".$workpath."/".$serversdic);
							print serversdat $adr."\n";
							print serversdic $addr."=".$type."\n";	
							close(serversdat);
							close(serversdic);
						}						
					}
				}
			}
		}
	}
}


sub seach_params2
{
	($file,$param) = @_;
	print_time("[seach_params2] file = ".$file);	
	print_time("[seach_params2] param = ".$param);	
	open(parameters, $file) or die "Error open file: $!";
	$parameter="null";
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
sub seach_string
{
	($file,$param) = @_;
	print_time("[seach_string] file = ".$file);		
	open(parameters, $file) or die "Error open file: $!";
	while(<parameters>) {
		chomp $_;
		$param_name=$_;
		if ($param_name eq $param)
		{
			#print "already exist\n";
			#print "param_name =  ".$param_name."\n";
			#print "param =  ".$param."\n";
			$parameter="yes";
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
sub print_time
{
	my $text=shift;
	chomp $text;
	chomp($text);
	open (serversdatlog,">> ".$workpath."/".$service."_serversdat.log");	
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	print serversdatlog "[DEBUG] [".$datetime_now."] [".$text."]\n";
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
	close(serversdatlog);
}