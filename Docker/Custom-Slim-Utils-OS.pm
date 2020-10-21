package Slim::Utils::OS::Custom;

use strict;

use base qw(Slim::Utils::OS::Linux);

use constant MUSIC_DIR => '/music';

sub initDetails {
	my $class = shift;

	$class->{osDetails} = $class->SUPER::initDetails();
	$class->{osDetails}->{osName} .= " (Docker)";

	return $class->{osDetails};
}

sub initPrefs {
	my ($class, $prefs) = @_;

	$prefs->{wizardDone} = 1;
	$prefs->{libraryname} = Slim::Utils::Strings::string('SQUEEZEBOX_SERVER');
	
	if (-d MUSIC_DIR) {
		$prefs->{mediadirs} = $prefs->{ignoreInImageScan} = $prefs->{ignoreInVideoScan} = [ MUSIC_DIR ];
	}
}

sub dirsFor {
	my ($class, $dir) = @_;

	my @dirs = $class->SUPER::dirsFor($dir);

	if ($dir eq 'music' && -d MUSIC_DIR) {
		push @dirs, MUSIC_DIR;
	}

	return wantarray() ? @dirs : $dirs[0];
}

# TODO - update checker

1;