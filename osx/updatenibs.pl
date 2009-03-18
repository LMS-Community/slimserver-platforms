#!/usr/bin/perl

use strict;
use File::Copy;
use File::Spec::Functions qw(catdir);
use Getopt::Long;


my ($folder, $nib, $strings);

GetOptions(
	'folder=s' => \$folder,
	'nib=s'    => \$nib,
	'strings=s'=> \$strings,
);

my $EN = catdir($folder, 'English.lproj', $nib);

unless (-d $EN && -r $EN) {
	print "Can't find English original resource '$EN'\n";
	exit;
}

opendir (PROJ, $folder) || die "can't open directory '$folder': $!\n";

foreach my $item (readdir(PROJ)) {

	# we only want localized resources
	if ($item =~ /\.lproj$/ && $item !~ /^English/i) {
		my $stringsFile = catdir($folder, $item, $strings);
		my $nibFolder   = catdir($folder, $item, $nib);
		my $nibBackup   = catdir($folder, $item, $nib . '2');
		
		unless (-f $stringsFile && -r $stringsFile) {
			print "Can't find $stringsFile\n";
			next;
		}
		
		unless (-d $nibFolder && -r $nibFolder) {
			print "Can't find $nibFolder\n";
			next;
		}

		$nibBackup =~ s/ /\\ /g;
		$nibFolder =~ s/ /\\ /g;

		`nibtool -d '$stringsFile' '$EN' -W $nibBackup && mv $nibBackup/* $nibFolder && rmdir $nibBackup`;
	}
}

close PROJ;