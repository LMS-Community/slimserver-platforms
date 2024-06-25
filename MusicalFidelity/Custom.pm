package Slim::Utils::OS::Custom;

use strict;
use base qw(Slim::Utils::OS::Linux);

# IMPORTANT: The folloiwng file will be used to verify we're an Encore device.
#            Initialization will fail if it does not exist.
use constant ENCORE_VERSION_FILE => '/usr/encore/encore-release';

# give our installation its own fancy OS name
sub initDetails {
	my $class = shift;

	$class->{osDetails} = $class->SUPER::initDetails();
	$class->{osDetails}->{osName} = "Encore OS";
	$class->{osDetails}->{communityLMS} = 1;

	return $class->{osDetails};
}

# use custom folders for settings, cache etc.
sub dirsFor {
	my ($class, $dir) = @_;

	my @dirs = ();

	if ($dir =~ /^(?:prefs)$/) {

		push @dirs, $::prefsdir || "/etc/encoreserver/prefs";

	} elsif ($dir eq 'log') {

		push @dirs, $::logdir || "/usr/encore/server/Logs";

	} elsif ($dir eq 'cache') {

		push @dirs, $::cachedir || "/media/data/Cache";

	} elsif ($dir eq 'music') {

		push @dirs, "/media/data/Music";

	} elsif ($dir eq 'playlists') {

		push @dirs, "/media/data/Playlist";

	} else {

		push @dirs, $class->SUPER::dirsFor($dir);

	}

	return wantarray() ? @dirs : $dirs[0];
}

# assume EN the default language if no locale is configured for the encore user
sub getSystemLanguage {
	my $class = shift;

	my $language = $class->SUPER::getSystemLanguage() || 'EN';

	return $language eq 'C' ? 'EN' : $language;
}

# buffer as much data in memory as possible - highly improves performance on systems with 1GB+ of RAM
sub canDBHighMem { 2 }

# we want to customize defaults for some prefs - put them here
sub initPrefs {
	my ($class, $prefs) = @_;

	# we are running in a known environment - don't show the wizard
	# $prefs->{wizardDone} = 1;

	# use our custom skin
	$prefs->{skin} = 'Encore';

	# override some defaults to our taste
	$prefs->{showArtist} = 1;
	$prefs->{useTPE2AsAlbumArtist} = 1;
	$prefs->{useUnifiedArtistsList} = 1;
	$prefs->{variousArtistAutoIdentification} = 1;
	$prefs->{itemsPerPage} = 500;
	$prefs->{groupdiscs} = 1;

	$prefs->{longdateFormat} = q(%A, |%d %B %Y);
	$prefs->{shortdateFormat} = q(%d/%m/%Y);
}

# plugins we don't even want to offer to the user
sub skipPlugins {
	my $class = shift;

	return (
		qw(
			ACLFileTest ImageBrowser SN
			PreventStandby MusicMagic
			UPnP
		),
		$class->SUPER::skipPlugins(),
	);
}

# don't store potential Squeezebox firmware updates on
# this system but let the players download directly
sub directFirmwareDownload { 1 };

# ignore this configuration unless we are running it on a Encore system
if (-f ENCORE_VERSION_FILE) {
	return 1;
}
