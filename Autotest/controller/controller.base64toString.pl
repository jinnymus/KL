#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use MIME::Base64 ();
use MIME::Base64;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8 decode_utf8);

$hash="QMW9RKySYjAgVlZz5qjzag==";

my $decoded_bin = decode_base64($hash);
$decoded = unpack "H*", $decoded_bin;
print "decoded = ".$decoded."\n";
