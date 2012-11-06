package LMSMigration;

use strict;

use FindBin qw($Bin);
use lib "$Bin";

use MsgBox;

my $PRODUCT_FOLDER = 'Squeezebox';

sub migrate {
	# shut down LMS/SBS
	my $check = 'ps -axww | grep "slimserver\.pl" | grep -v grep | cat';
	
	if ( `$check` =~ /^\s*(\d+) / ) {
		kill 15, $1;
	}
	
	# Wait for it to stop
	for my $i (0 .. 9) {
		last if !`$check`;
		sleep 1;
	}
	
	# If it didn't quit, fail
	if ( `$check` ) {
		MsgBox->show('TITLE', 'PLEASE_STOP_LMS');
		exit 1;
	}
	
	my $home = $ENV{HOME};

	for my $name ("Squeezebox Server", "Squeezebox") {

		if ( -e "$home/Library/PreferencePanes/$name.prefPane" ) {
			`rm -r "$home/Library/PreferencePanes/$name.prefPane" 2>&1`;
		}
		
		if ( -e "/Library/PreferencePanes/$name.prefPane" ) {
			`rm -r "/Library/PreferencePanes/$name.prefPane" 2>&1`;
		}
	}
	
	# XXX - re-introduce migration from Squeezebox Server et al.?
}

1;
