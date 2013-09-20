#!/usr/bin/perl -w

use strict;
use warnings;

#use Data::Dump;
use File::Spec::Functions qw(splitdir);
use XML::Simple qw(XMLin);

my ($file, $target) = @ARGV;

if ( !(-f $file && -r _) ) {
	warn "Can't read file '$file' or file not found\n";
	exit;
}

my $data = XMLin($file);

my @path = grep { $_ && $_ !~ /addon/ } splitdir($target);

print $path[0] . '!!' . $data->{$path[0]};

1;