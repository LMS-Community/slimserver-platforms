#!/usr/bin/perl

# read strings.txt file and split it up into ReadyNAS specific SQUEEZEBOX.str files for every language

use strict;
use Data::Dump qw(dump);
use File::Path qw(make_path);
use utf8;

open(STRINGS, "<strings.txt") or die "$!";

my %langs = (
	CS => 'cs',
	DA => 'da',
	DE => 'de',
	EN => 'en-us',
	ES => 'es',
	FI => 'fi',
	FR => 'fr',
	IT => 'it',
	NL => 'nl',
	NO => 'no',
	PL => 'pl',
	RU => 'ru',
	SV => 'sv',
);

my $string;
my %data;

while (<STRINGS>) {

	# remove newline chars and trailing tabs/spaces
	chomp; s/[\t\s]+$//; 

	# this is a STRING ID
	if (/^[A-Z0-9]/) {
		$string = $_;
		# add {FILE}{STRING} to %DATA, with blanks for all supported langs
		for my $lang (keys %langs) {
			$data{$lang}{$string} = "";
		}
	}

	# this is a TRANSLATION
	elsif ($string ne "" && /^[\t\s]+[A-Z][A-Z]/) {
		s/^[\t|\s]+//;
		my ($lang, @translation) = split /[\t]+/;
		$data{$lang}{$string} = $translation[0];
	}
}

close(STRINGS);

for my $lang (keys %data) {
	my $dir = 'addon_template/language/' . $langs{$lang};
	make_path($dir) unless -d $dir;
	
	my $stringsFile = $dir . '/SQUEEZEBOX.str';
	open(STRINGS, ">:utf8", $stringsFile) or die "Couldn't open $stringsFile for writing: $!\n";
	binmode STRINGS;

	while (my ($name, $string) = each %{$data{$lang}}) {
		print STRINGS $name . '::::' . "$string\n" if $string;
	}
	
	close STRINGS;
}
