#!/usr/bin/perl
use Time::localtime;
use Time::HiRes;
use v5.10;
use MIME::Base64 ();
use MIME::Base64;
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Encode qw(encode_utf8);
use Encode;
use Unicode::String;
use bytes;
use Switch;

$md5=shift;

my $bin = pack "H*", $md5;
my $encoded = encode_base64($bin);

print $encoded."\n";