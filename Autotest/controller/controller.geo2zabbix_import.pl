#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use HTTP::Request;
use LWP::UserAgent;
$ua = LWP::UserAgent->new;
	
$type=shift;	
$print=shift;	

print_log("type = ".$type);	
	
if ($type eq "screens")	
{
	open(export,"/export/geo/zabbix_servers_screens.xml");
}
else
{
	open(export,"/export/geo/zabbix_servers_row.xml");
}
unlink ("/export/geo/zabbix_import.log");
my $server="62.128.100.31";
my $url="http://".$server."/zabbix/api_jsonrpc.php";
my $req;
my $xml;
@xml_all=<export>;
foreach my $line (@xml_all)
{
	$xml=$xml.$line;
}
#print "xml = ".$xml."\n";
#apiinfo.version
#\"method\": \"configuration.import\",

$json_userlogin="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.login\",
    \"params\": {
		\"user\": \"admin\", 
		\"password\": \"zabbix\"
	},
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
my $json_hosts="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"groups\" :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"hosts\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"graphs\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },				
            \"screens\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },			
            \"templateLinkage\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
			},		
			\"items\"      : {
			  \"createMissing\":   true,
			  \"updateExisting\":   true
			},
            \"applications\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            }			 
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
$json_screens="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"screens\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            }
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
$json_graphs="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
			\"graphs\"      : {
			  \"createMissing\":   true,
			  \"updateExisting\":   true
			}
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
$json_items="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"groups\" :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
			\"items\"      : {
			  \"createMissing\":   true,
			  \"updateExisting\":   true
			}
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
$json_templates="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"groups\" :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
			\"items\"      : {
			  \"createMissing\":   true,
			  \"updateExisting\":   true
			},
            \"templates\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"templateScreens\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"graphs\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            }
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";

$json_full_1="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"groups\" :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"hosts\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"screens\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },			
            \"templateLinkage\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
			},		
			\"items\"      : {
			  \"createMissing\":   true,
			  \"updateExisting\":   true
			},
            \"applications\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            }				 
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
$json_full_2="{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.import\",
    \"params\": {
        \"user\": \"admin\", 
        \"password\": \"zabbix\",	
        \"format\": \"xml\",
        \"rules\": {
            \"groups\" :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"applications\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },			
            \"hosts\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },
            \"graphs\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },				
            \"maps\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },			
            \"screens\"     :   {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
            },			
            \"templateLinkage\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
             },			
            \"templates\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
             },
            \"templateScreens\" :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
             },			 
             \"triggers\"  :  {
                  \"createMissing\":  true,
                  \"updateExisting\":  true
             },
             \"items\"      : {
                  \"createMissing\":   true,
                  \"updateExisting\":   true
             }		
        },
        \"source\": \"<!--?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?-->".$xml."\"
    },
    \"auth\": \"2f26a8c205438d8adcac655ae4492042\",	
    \"id\": 1
}";
#\"true\"

if ($type eq "hosts")
{
	$json=$json_hosts;
}
elsif ($type eq "templates")
{
	$json=$json_templates;
}
elsif ($type eq "screens")
{
	$json=$json_screens;
}
elsif ($type eq "graphs")
{
	$json=$json_items;
}
elsif ($type eq "items")
{
	$json=$json_items;
}


if ($print eq "yes")
{
	print_log("json = ".$json);	
}

$req = HTTP::Request->new(POST=>$url);
$req->authorization_basic('admin', 'zabbix');
$req->content_type('application/json-rpc');
$req->content($json);
$req->header("Content-Length", length($json));
$ua->timeout(2500);
my $res = $ua->request($req);
$response=$res->content;

print_log("response = ".$response);
	
close(export);

sub replace_quot
{
	my $mask=shift;
	$mask=~ s/"/DOUBLEQUOT/;
	return $mask;
}
sub replace_quot_true
{
	my $mask_true=shift;
	$mask_true=~ s/DOUBLEQUOT/\\"/;
	return $mask_true;
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
sub print_log
{
	my $message=shift;
	my $datetime_now=get_date();		
	open(file,">> /export/geo/zabbix_import.log");
	print file "[DEBUG][".$datetime_now."] ".$message."\n";
	print "[DEBUG][".$datetime_now."] ".$message."\n";
	close(file);
}

sub get_date
{
	my $type=shift;
	my $tm_now = localtime;
	my $date;
	#my $datetime=($tm_now->year+1900).'-'.(($tm_now->mon)+1).'-'.$tm_now->mday.'_'.$tm_now->hour.':'.$tm_now->min.':'.$tm_now->sec;
	$mon=$tm_now->mon+1;
	$mday=$tm_now->mday;
	$hour=$tm_now->hour;
	$min=$tm_now->min;
	$sec=$tm_now->sec;
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
		$date=($tm_now->year+1900).($mon_str).$mday_str.$hour_str.$min_str;
	}
	else
	{
		$date=($tm_now->year+1900).'-'.($mon_str).'-'.$mday_str.'_'.$hour_str.':'.$min_str.':'.$sec_str;
	}
	return $date;
}