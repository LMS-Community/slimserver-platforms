#!/usr/bin/perl

use strict;
use File::Spec::Functions qw(catdir);
use Getopt::Long;


my ($folder, $nib);

GetOptions(
	'folder=s' => \$folder,
	'nib=s'    => \$nib,
);

my $strings = $nib;
$strings =~ s/nib$/strings/;

opendir (PROJ, $folder) || die "can't open directory '$folder': $!\n";

foreach my $item (readdir(PROJ)) {

	# we only want localized resources
#	if ($item =~ /\.lproj$/ && $item !~ /^English/i) {
	if ($item =~ /\.lproj$/) {
		my $stringsFile = catdir($folder, $item, $strings);
		my $nibFolder   = catdir($folder, $item, $nib);
		
		unless (-d $nibFolder && -r $nibFolder) {
			print "Can't find NIB file $nibFolder\n";
			next;
		}

		$nibFolder =~ s/ /\\ /g;
		$stringsFile =~ s/ /\\ /g;

		`ibtool --generate-strings-file $stringsFile $nibFolder`;
	}
}

close PROJ;