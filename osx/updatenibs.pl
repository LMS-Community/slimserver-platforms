#!/usr/bin/perl

use strict;
use File::Copy;
use File::Spec::Functions qw(catdir);
use Getopt::Long;


my ($folder, $nib);

GetOptions(
	'folder=s' => \$folder,
	'nib=s'    => \$nib,
);

my $EN = catdir($folder, 'English.lproj', $nib);

unless (-d $EN && -r $EN) {
	print "Can't find English original resource '$EN'\n";
	exit;
}

my $strings = $nib;
$strings =~ s/nib$/strings/;

opendir (PROJ, $folder) || die "can't open directory '$folder': $!\n";

foreach my $item (readdir(PROJ)) {

	# we only want localized resources
	if ($item =~ /\.lproj$/ && $item !~ /^English/i) {
		my $stringsFile = catdir($folder, $item, $strings);
		my $nibFolder   = catdir($folder, $item, $nib);
		
		unless (-f $stringsFile && -r $stringsFile) {
			print "Can't find strings file $stringsFile\n";
			next;
		}
		
		unless (-d $nibFolder && -r $nibFolder) {
			print "Can't find NIB file $nibFolder\n";
			next;
		}

		$nibFolder =~ s/ /\\ /g;
		
		print "Merging $nibFolder\n";

		`ibtool '$EN' --strings-file '$stringsFile' --write $nibFolder`;
	}
}

close PROJ;