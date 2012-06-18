package MsgBox;

# Copyright 2001-2012 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License, 
# version 2.

# This module provides some functions compatible with functions
# from the core server code, without their overhead.
# These functions are called by helper applications like the tray icon
# or the control panel. 

use strict;

use FindBin qw($Bin);
use lib "$Bin";

my %strings;
my $language;

sub init {
	my $class = shift;
	
	$language ||= $class->_getSystemLanguage();
		
	my $string     = '';
	my $language   = '';
	my $stringname = '';

	my $file = "$Bin/strings.txt";

	open(STRINGS, "<:utf8", $file) || do {
		warn "Couldn't open file [$file]!";
		return;
	};

	foreach my $line (<STRINGS>) {
		chomp($line);
		
		next if $line =~ /^#/;
		next if $line !~ /\S/;

		if ($line =~ /^(\S+)$/) {

			$stringname = $1;
			$string = '';
			next;

		} elsif ($line =~ /^\t(\S*)\t(.+)$/) {

			$language = uc($1);
			$string   = $2;

			$strings{$stringname}->{$language} = $string;
		}
	}

	close STRINGS;
}

sub show {
	my ($class, $title, $msg) = @_;
	
	$class->init() if !$language;

	$title = $class->string($title);
	$msg   = $class->string($msg);

	my $ok = $class->string('OK');
	
	`/usr/bin/osascript <<-EOF
	
	    tell application "System Events"
	        activate
	        display dialog "$msg" buttons { "$ok" } with title "$title" default button 1
	    end tell
	
	EOF`;
}

# return localised version of string token
sub string {
	my $class = shift;
	my $name = shift;
	
	my $lang = shift || $language;
	
	my $string = $strings{ $name }->{ $lang } || $strings{ $name }->{ $language } || $strings{ $name }->{'EN'} || $name;
	
	if ( @_ ) {
		$string = sprintf( $string, @_ );
	}	
	
	return $string;
}

sub _getSystemLanguage {
	# Will return something like:
	# (en, ja, fr, de, es, it, nl, sv, nb, da, fi, pt, "zh-Hant", "zh-Hans", ko)
	# We want to use the first value. See:
	# http://gemma.apple.com/documentation/MacOSX/Conceptual/BPInternational/Articles/ChoosingLocalizations.html
	my $language = $ENV{LANG};
	if (open(LANG, "/usr/bin/defaults read 'Apple Global Domain' AppleLanguages |")) {

		for (<LANG>) {
			if (/\b(\w\w)\b/) {
				$language = $1;
				last;
			}
		}

		close(LANG);
	}
	
	$language = uc($language);
	$language =~ s/\.UTF.*$//;
	$language =~ s/(?:_|-|\.)\w+$//;

	return $language || 'EN';
}

1;