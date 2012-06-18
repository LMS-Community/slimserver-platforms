package LMSMigration;

use strict;

use FindBin qw($Bin);
use lib "$Bin";

use MsgBox;

my $PRODUCT_FOLDER = 'UEMusicLibrary';

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


	# try to migrate existing settings
	if ( !-e "$home/Library/Application\ Support/$PRODUCT_FOLDER" ) {
		if ( -e "$home/Library/Application\ Support/Squeezebox" ) {
			`ditto "$home/Library/Application Support/Squeezebox" "$home/Library/Application Support/$PRODUCT_FOLDER"`;
			`grep -v "/Squeezebox" "$home/Library/Application Support/Squeezebox/server.prefs" | grep -v httpport > "$home/Library/Application Support/$PRODUCT_FOLDER/server.prefs"`;
		}
		elsif ( -e '/Library/Application\ Support/Squeezebox' ) {
			`ditto "/Library/Application Support/Squeezebox" "$home/Library/Application Support/$PRODUCT_FOLDER"`;
			`grep -v "/Squeezebox" "/Library/Application Support/Squeezebox/server.prefs" | grep -v httpport > "$home/Library/Application\ Support/$PRODUCT_FOLDER/server.prefs"`;
		}
	}

}

1;
