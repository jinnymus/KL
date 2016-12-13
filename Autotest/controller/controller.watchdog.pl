#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use Net::Ping;
use v5.10;
use Time::Piece;
use Try::Tiny;
#use strict;

my $tm = localtime;
my $type=shift;
delete_tmp_files("\.log");
#$datetime=($tm->year+1900).'-'.(($tm->mon)+1).'-'.$tm->mday;
my $date_for_check=get_date("folder");
$watchdog_log_name="watchdog_".$date_for_check.".log";
	
open(resultlog,"> /export/watchdog/restarted.dat");	
$resultlog_status=0;
$status=seach_params2("/export/status_watchdog.dat","watchdog");	
my $mail_email_watchdog=seach_params2("/export/parameters.dat","mail_email_watchdog");	
print_log("mail_email_watchdog = ".$mail_email_watchdog);
print_log("check status");
$alive=0;			
if ($status eq "Stopped" || $type eq "force")
{
	print_log("update_status status");
	my $update_status=`/export/controller/controller.watchdog_status_updater.sh watchdog Stopped Running`;
	open(monitor_testplan,"/export/monitor_testplan.dat");
	my @monitor_testplan = <monitor_testplan>;
	unlink("/export/watchdog/".$watchdog_log_name);
	foreach my $machine (@monitor_testplan)
	{
		$alive=0;	
		chomp $_;
		#$machine=$_;
		chomp $machine;
		print_log("[ ".$machine." ] monitor_testplan machine = ".$machine);
		$machine_ip=seach_params_ip("/export/ip_adresses.dat",$machine);
		chomp $machine_ip;
		print_log("[ ".$machine." ] machine_ip = ".$machine_ip);
		my $p =Net::Ping->new("icmp");
		if ($p->ping($machine_ip)) 
		{
			#open(logg,"/export/watchdog/watchdog_log_name");
			print_log("[ ".$machine." ] machine $machine_ip is alive");
			$alive=1;			
		} 
		else 
		{
			print_log("[ ".$machine." ] machine $machine_ip is unreachable");			
			my $machine_line=get_full_line("/export/ip_adresses.dat",$machine);
			my $machine_type=cut($machine_line,"4",";");
			if ($machine_type eq "host")
			{
				print_log("[ ".$machine." ] machine $machine_ip is host");
				print resultlog "Machine ".$machine." [restart_esx] has restarted because unreachable<br>\n";
				print_log("[ ".$machine." ] Machine ".$machine." [restart_esx] has restarted because unreachable");
				$resultlog_status++;
				#restart_esx($machine,$machine_ip);
				my @ssh_console=restart_esx($machine,$machine_ip);
				foreach (@ssh_console)
				{
					chomp $_;
					print_log("[ ".$machine." ] ssh_result _ = ".$_);
				}				
			}
			elsif ($machine_type eq "jail")
			{
				print_log("[ ".$machine." ] machine $machine_ip is jail");
				my $machine_host=cut($machine_line,"5",";");
				print_log("[ ".$machine." ] Machine ".$machine." [restart_jail] has restarted because unreachable");
				print resultlog "Machine ".$machine." [restart_jail] has restarted because unreachable<br>\n";
				$resultlog_status++;
				#restart_jail($machine,$machine_ip,$machine_host);
				my @ssh_console=restart_esx($machine,$machine_ip,$machine_host);
				foreach (@ssh_console)
				{
					chomp $_;
					print_log("[ ".$machine." ] ssh_result _ = ".$_);
				}						
			}
			else
			{
				print_log("[ ".$machine." ] machine $machine_ip unknown type");
			}
		}
		#sleep 300;
	}
	print_log("[ main ] check_tests");
	check_tests();	
	#sleep 10;
	print_log("[ main ] update_status2");
	$update_status2=`/export/controller/controller.watchdog_status_updater.sh watchdog Running Stopped`;	
	print_log("[ main ] update_status2 = ".$update_status2);
	open(status,"/export/status_watchdog.dat");
	@status=<status>;
	foreach my $line (@status)
	{
		chomp $line;
		print_log("[ main ] status _ = ".$line);	
	}
}
else
{
	print_log("[ main ] unlink watchdog_running");
	print_log("[ main ] Watchdog - Running");
	unlink("/export/watchdog/watchdog_running");
	print_log("[ main ] print mail");
	open(mail2,">> /export/watchdog/watchdog_running");
	print mail2 "Watchdog running ".$machine;
	#open(logg,">> /export/".$watchdog_log_name);	
	#print_log("Watchdog running";
	print_log("[ main ] send mail");
	print_log("[ main ] mail_email_watchdog = ".$mail_email_watchdog);
	print_log("[ main ] watchdog_log_name = ".$watchdog_log_name);
	my $subject="Controller. Monitoring tests. Watchdog - Running";
	print_log("[main] subject = ".$subject);
	my $mail2=`/export/controller/controller.mail_send.pl /export/watchdog/watchdog_running "$mail_email_watchdog" "$subject" "multipart" /export/watchdog/$watchdog_log_name /export/watchdog`;
	close(mail2);
	close(logg);
}
if ($resultlog_status > 0)
{
	print_log("[ main ] resultlog_status > 0");
	print_log("[ main ] Watchdog - Restarted machines");
	my $subject="Controller. Monitoring tests. Watchdog - Restarted machines";
	my $mail3=`/export/controller/controller.mail_send.pl /export/watchdog/restarted.dat "$mail_email_watchdog" "$subject" "multipart" /export/watchdog/$watchdog_log_name /export/watchdog`;
	close(resultlog);
	print_log("[ main ] ".$resultlog_status." machines restarted");
}
else
{
	print_log("[ main ] resultlog_status <> 0 ".$resultlog_status." machines restarted");
	my $subject="Controller. Monitoring tests. Watchdog - No Restarted machines";
	my $mail3=`/export/controller/controller.mail_send.pl /export/watchdog/restarted.dat "$mail_email_watchdog" "$subject" "multipart" /export/watchdog/$watchdog_log_name /export/watchdog`;
	close(resultlog);	
}

sub restart_esx
{
	my $machine=shift;
	my $machine_ip=shift;
	print_log("[ ".$machine." ] [restart_esx]");
	my $controller_esx_ip=seach_params2("/export/parameters.dat","controller_esx_ip");	
	chomp $controller_esx_ip;
	print_log("[ ".$machine." ] [restart_esx] controller_esx_ip = ".$controller_esx_ip);		
	
	my $run="ssh $controller_esx_ip \"/export/controller/controller.esx_restart.sh $watchdog_log_name $machine\"";
	#my @ssh_console=`$run`;	
	print_log("[ ".$machine." ] [restart_esx] run = ".$run);
	print_log("[ ".$machine." ] [restart_esx] ssh result:");	
	foreach (@ssh_console)
	{
		chomp $_;
		print_log("[ ".$machine." ] [restart_esx] ssh_result _ = ".$_);	
	}		
	return @ssh_console;
}
sub restart_esx_ping
{
	my $machine=shift;
	my $machine_ip=shift;
	my $alive=0;	
	print "[ ".$machine." ] [restart_esx].\n";	
	
	print "[ ".$machine." ] machine $machine_ip is not reachable.\n";
	print_log("[ ".$machine." ] machine $machine_ip is not reachable");
	sleep 900;
	for (my $i=0;$i<100;$i++)
	{
		print_log("[ ".$machine." ] i = ".$i);
		my $p2 =Net::Ping->new("icmp");
		if ($p2->ping($machine_ip)) 
		{
			print "[ ".$machine." ] machine $machine_ip is alive.\n";
			print_log("[ ".$machine." ] machine $machine_ip is alive");
			last;
			$alive=1;
		}
		else
		{
			#$alive=0;			
		}
		sleep 10;
	}
	if ($alive == 0)
	{

		unlink("/export/watchdog/watchdog_mail_z");				
		open(mail_z,"/export/watchdog/watchdog_mail_z");
		print mail_z "Watchdog restarted machine ".$machine;
		print_log("Watchdog restarted ".$machine);
		my $mail_z=`/export/controller/controller.mail_send.pl /export/watchdog/watchdog_mail_z "$mail_email_watchdog" "Controller. Watchdog - Restart" "multipart" /export/watchdog/$watchdog_log_name /export/watchdog`;
		close(mail_z);
		#@ssh_console=`ls`;
		my @ssh_console=restart_esx();
		foreach (@ssh_console)
		{
			chomp $_;
			print "[ ".$machine." ] ssh_result _ = ".$_."\n";
		}
		sleep 600;
		my $p2 =Net::Ping->new("icmp");
		if ($p2->ping($machine_ip)) 
		{
			print "[ ".$machine." ] machine $machine_ip is alive.\n";
			print_log("[ ".$machine." ] machine $machine_ip is alive");
		} 
		else 
		{
			unlink("/export/watchdog/watchdog_mail");
			open(mail,"/export/watchdog/watchdog_mail");
			print mail "Watchdog restarted machine but it fail ".$machine;
			print_log("Watchdog restarted machine but it fail ".$machine);
			my $mail=`/export/controller/controller.mail_send.pl /export/watchdog/watchdog_mail "$mail_email_watchdog" "Controller. Watchdog - Restart. Fail" "multipart" /export/watchdog/$watchdog_log_name /export/watchdog`;
			close(mail);
		}
		close(logg);
	}	
}
sub get_date
{
	my $type=shift;
	my $tm_now = localtime;
	my $date;
	#my $datetime=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	my $mon=$tm_now->mon+1;
	my $mday=$tm_now->mday;
	my $hour=$tm_now->hour;
	my $min=$tm_now->min;
	my $sec=$tm_now->sec;
	my $mon_str;
	my $mday_str;
	my $hour_str;
	my $min_str;
	my $sec_str;
	
	#month
	if ($mon < 10)
	{
		$mon_str="0".$mon;
	}
	else
	{
		$mon_str=$mon;
	}	
	#day
	if ($mday < 10)
	{
		$mday_str="0".$mday;
	}
	else
	{
		$mday_str=$mday;
	}		
	#hour	
	if ($hour < 10)
	{
		$hour_str="0".$hour;
	}
	else
	{
		$hour_str=$hour;
	}
	#min		
	if ($min < 10)
	{
		$min_str="0".$min;
	}
	else
	{
		$min_str=$min;
	}
	#sec
	if ($sec < 10)
	{
		$sec_str="0".$sec;
	}
	else
	{
		$sec_str=$sec;
	}
	if ($type eq "folder")
	{
		$date=($tm_now->year).($mon_str).$mday_str.$hour_str.$min_str;
	}
	else
	{
		$date=($tm_now->year).'-'.($mon_str).'-'.$mday_str.'_'.$hour_str.':'.$min_str.':'.$sec_str;
	}
	return $date;
}
sub restart_jail
{
	my $machine=shift;
	my $machine_ip=shift;
	my $machine_host=shift;
	my $alive=0;
	print_log("[ ".$machine." ] [restart_jail] start");	
	print_log("[ ".$machine." ] [restart_jail] machine $machine_ip is restart_jail");
	#my $run="ssh ".$machine_host." \"/etc/rc.d/jail restart ".$machine."\"";
	my $machine_host_ip=seach_params_ip("/export/ip_adresses.dat",$machine_host);
	my $run='ssh '.$machine_host_ip.' \'/etc/rc.d/jail restart '.$machine.'\'';
	print_log("[ ".$machine." ] [restart_jail] run = ".$run);
	#my @ssh_console=`$run`;
	my @ssh_console;
	foreach (@ssh_console)
	{
		chomp $_;
		print_log("[ ".$machine." ] [restart_jail] ssh_result _ = ".$_);
	}
	return @ssh_console;
}

sub check_tests
{
	print_log("[ check_tests ] start");
	opendir(tests,"/export/tests") or die $!; 
	my @files = grep /\.dat$/, readdir(tests); 
	foreach my $file (@files)
	{
		print_log("[ ".$file." ] [check_tests] check status");
		my $last_test=seach_params2("/export/tests/".$file,"last_test");
		print_log("[ ".$file." ] [check_tests] last_test = ".$last_test);
		my $date_for_check=get_date_for_check();
		print_log("[ ".$file." ] [check_tests] date_for_check = ".$date_for_check);		
		my $datefiledate;
		try 
		{
			print_log("[ ".$file." ] [check_tests] try convert last_test = ".$last_test);					
			$datefiledate = Time::Piece->strptime($last_test, "%Y%m%d%H%M");
			print_log("[ ".$file." ] [check_tests] last_test = ".$last_test);		
			print_log("[ ".$file." ] [check_tests] last_test datefiledate = ".$datefiledate);
			print_log("[ ".$file." ] [check_tests] last_test date_for_check = ".$date_for_check);
			if ($datefiledate <= $date_for_check)
			{
				print_log("[ ".$file." ] [check_tests] restart machine");
				my $machine_name=cut($file,"0",".");
				print_log("[ ".$file." ] [check_tests] restart machine_name ".$machine_name);
				my $machine_line=get_full_line("/export/ip_adresses.dat",$machine_name);
				my $machine_type=cut($machine_line,"4",";");
				my $machine_ip=cut($machine_line,"2",";");
				print_log("[ ".$file." ] [check_tests] restart machine_type ".$machine_type);
				print_log("[ ".$file." ] [check_tests] restart machine_ip ".$machine_ip);
				if ($machine_type eq "host")
				{
					print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] machine_ip $machine_ip machine_name $machine_name type is host");
					print resultlog "Machine ".$machine_name." [restart_esx] has restarted because test ".$datefiledate." <= ".$date_for_check."<br>\n";
					print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] Machine ".$machine_name." [restart_esx] has restarted because test ".$datefiledate." <= ".$date_for_check);
					$resultlog_status++;								
					#restart_esx($machine_name,$machine_ip);
					my @ssh_console=restart_esx($machine_name,$machine_ip);
					foreach (@ssh_console)
					{
						chomp $_;
						print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] ssh_result _ = ".$_);
					}					
				}
				elsif ($machine_type eq "jail")
				{
					print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] machine $machine_ip type is jail");
					my $machine_host=cut($machine_line,"5",";");
					print resultlog "Machine ".$machine_name." [restart_jail] has restarted because test ".$datefiledate." <= ".$date_for_check."<br>\n";
					print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] restart_jail] has restarted because test ".$datefiledate." <= ".$date_for_check);
					$resultlog_status++;				
					#restart_jail($machine_name,$machine_ip,$machine_host);
					my @ssh_console=restart_jail($machine_name,$machine_ip,$machine_host);
					foreach (@ssh_console)
					{
						chomp $_;
						print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] ssh_result _ = ".$_);
					}				
				}
				else
				{
					print_log("[ ".$file." ] [check_tests] [ ".$machine_name." ] machine $machine_ip unknown type");				
				}			
			}			
		}
		catch
		{
			print_log("[ ".$file." ] [check_tests] last_test = ".$last_test." fail convert error ".$_);				
		};
	}
	closedir tests; 	
}

sub get_date_for_check
{
	my $tm = localtime;
	my $year=$tm->year;
	my $mon=($tm->mon);
	my $day=$tm->mday;
	my $hour=$tm->hour;
	print_log("[ get_date_for_check ] hour before convert = ".$hour);		
	$hour=$tm->hour-6;
	print_log("[ get_date_for_check ] hour for convert = ".$hour);		
	print_log("[ get_date_for_check ] day before convert = ".$day);			
	my $min=$tm->min;
	my $sec=$tm->sec;

	if ($mon < 10)
	{
		$mon="0".$mon;
	}
	else
	{
		$mon=$mon;
	}
	if ($day < 10)
	{
		$day="0".$day;
	}
	else
	{
		$day=$day;
	}
	if ($hour < 0)
	{
		$hour=24 + $hour;
		if ($day > 1)
		{
			$day=$tm->mday-1;
		}
		else
		{
			print_log("[ get_date_for_check ] day for convert = ".$day);		
			$day=32-$day;
			if ($mon > 1)
			{
				$mon=$tm->mon-1;
			}
			if ($mon < 10)
			{
				$mon="0".$mon;
			}
			else
			{
				$mon=$mon;
			}			
		}
		print_log("[ get_date_for_check ] day for convert = ".$day);
		print_log("[ get_date_for_check ] mon for convert = ".$mon);
		if ($day < 10)
		{
			$day="0".$day;
		}		
	}	
	elsif ($hour < 10)
	{
		$hour="0".$hour;
	}
	else
	{
		$day=$day;
	}
	if ($min < 10)
	{
		$min="0".$min;
	}
	else
	{
		$min=$min;
	}
	if ($sec < 10)
	{
		$sec="0".$sec;
	}
	else
	{
		$sec=$sec;
	}

	my $datetime=$year.$mon.$day;

	if ($mon == 1)
	{
		$mon_need=12;
		$year_need=$year-1;
	}
	else
	{
		$mon_need=$mon;
		$year_need=$year;
	}
	print_log("[ get_date_for_check ] hour final convert = ".$hour);	
	print_log("[ get_date_for_check ] day final convert = ".$day);	
	print_log("[ get_date_for_check ] mon_need final convert = ".$mon_need);	
	my $datetime_need=$year_need.$mon_need.$day.$hour.$min;
	print_log("[ get_date_for_check ] datetime final convert = ".$datetime_need);		
	my $datetime_need_date;
	try
	{
		print_log("[ get_date_for_check ] datetime try convert = ".$datetime_need);
		$datetime_need_date = Time::Piece->strptime($datetime_need, "%Y%m%d%H%M");
	}
	catch
	{
		print_log("[ get_date_for_check ] datetime final convert = ".$datetime_need." fail convert error = ".$_);
	};
	print_log("[ get_date_for_check ] return datetime_need_date = ".$datetime_need_date);
	return $datetime_need_date;
}

sub seach_params_ip
{
	($file,$param) = @_;
	open(parameters, $file) or die "Error open file: $!";
	while(<parameters>) {
		$param_name=cut($_,"0",";");
		if ($param_name eq $param)
		{
			$parameter=cut($_,"2",";");
		}
	};
	close(parameters);
	chomp $parameter;
return $parameter;
}
sub get_full_line
{
	($file,$param) = @_;
	open(parameters, $file) or die "Error open file: $!";
	while(<parameters>) {
		$param_name=cut($_,"0",";");
		if ($param_name eq $param)
		{
			$parameter=$_;
		}
	};
	close(parameters);
	chomp $parameter;
return $parameter;
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
	if ($delimeter eq ".")
	{
		@a=split("\\.", $string);
	}
	else
	{
		@a=split("$delimeter", $string);
	}
	$value=$a[$number];
return $value;
}
sub print_log
{
	$text=shift;
	my $tm_now = localtime;
	my $datetime_now=($tm_now->year).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	#my $watchdog_log_name="watchdog_".$datetime_now.".log";
	open(logg,">> /export/watchdog/".$watchdog_log_name);		
	print "[DEBUG] [".$datetime_now."] [".$text."]\n";
	print logg "[DEBUG] [".$datetime_now."] [".$text."]\n";	
	close(logg);
}
sub delete_tmp_files
{
	my $dir="";
	my $files=shift;
	my $path="/export/watchdog";
	print_log("[delete_tmp_files] dir = ".$dir);
	print_log("[delete_tmp_files] files = ".$files);
	print_log("[delete_tmp_files] path = ".$path);	
	opendir(DIR, $path."/".$dir);
	@FILES= readdir(DIR); 
	print_log("[delete_tmp_files] count files = ".scalar(@FILES));
	@files_for_delete=grep(/$files/,@FILES);
	foreach my $file (@files_for_delete)
	{
		print_log("[delete_tmp_files] file = ".$path."/".$dir."/".$file);		
		unlink($path."/".$dir."/".$file);
	}
	#system("rm -rf ".$path."/mail/*");
	#system("rm -rf ".$path."/_mail_attaches/*");
	#system("rm -rf ".$path."/*.log");
	#system("rm -rf ".$path."/logs/*.log");
}