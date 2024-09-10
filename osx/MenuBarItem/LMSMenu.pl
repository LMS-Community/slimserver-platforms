#!./bin/perl -Iserver/CPAN -Iserver -I.

use strict;

use File::Spec::Functions qw(catfile);
use IO::Socket::INET;
use JSON::PP;

use LMSMenuAction;

binmode(STDOUT, ":utf8");
our $STRINGS = decode_json(do {
    local $/ = undef;
    open my $fh, "<", 'LMSMenu.json'
        or die "could not open LMSMenu.json: $!";
    <$fh>;
});

my $lang = uc(substr(`/usr/bin/defaults read -g AppleLocale` || 'EN', 0, 2));

use constant PRODUCT_NAME => 'Squeezebox';
# use constant LOG_FOLDER => catdir($ENV{HOME}, 'Library', 'Logs', PRODUCT_NAME);
use constant PREFS_FILE => catfile($ENV{HOME}, 'Library', 'Application Support', PRODUCT_NAME, 'server.prefs');

sub getPort {
	my $port = getPref('httpport');
	my $remote = IO::Socket::INET->new(
		Proto    => 'tcp',
		PeerAddr => '127.0.0.1',
		PeerPort => $port,
	);

	if ( $remote ) {
		close $remote;
		return $port;
	}

	return;
}

sub getUpdate {
	my $updatesFile = catfile(getPref('cachedir'), 'updates', 'server.version');
	my $update;

	if (-r $updatesFile) {
		open(UPDATE, '<', $updatesFile) or return;
		chomp $_;

		while (<UPDATE>) {
			if ($_ && -r $_) {
				$update = $_;
				last;
			}
		}

		close(UPDATE);
	}

	return $update;
}

sub getPref {
	my $pref = shift;
	my $ret;

	if (-r PREFS_FILE) {
		open(PREF, '<', PREFS_FILE) or return;

		while (<PREF>) {
			if (/^$pref: ['"]?(.*)['"]?/) {
				$ret = $1;
				$ret =~ s/^['"]//;
				$ret =~ s/['"\s]*$//s;
				last;
			}
		}

		close(PREF);
	}

	return $ret;
}

sub getString {
	my ($token) = @_;
	return $STRINGS->{$token}->{$lang} || $STRINGS->{$token}->{EN};
}

sub printMenuItem {
	my ($token, $icon) = @_;
	$icon = "MENUITEMICON|$icon|" if $icon;

	my $string = getString($token) || $token;
	print "$icon$string\n";
}

my $httpPort = getPort();
my $update = getUpdate();

if (scalar @ARGV > 0) {
	LMSMenuAction::handleAction($httpPort, $update);
}
else {
	my $autoStartItem = -f catfile($ENV{HOME}, 'Library', 'LaunchAgents', 'org.lyrion.lyrionmusicserver.plist')
		? 'AUTOSTART_ON'
		: 'AUTOSTART_OFF';

	if ($httpPort) {
		printMenuItem('OPEN_GUI');
		printMenuItem('OPEN_SETTINGS');
		print("----\n");
		printMenuItem('STOP_SERVICE');
		printMenuItem($autoStartItem);
	}
	else {
		printMenuItem('START_SERVICE');
		printMenuItem($autoStartItem);
	}

	if ($update) {
		print("----\n");
		printMenuItem('UPDATE_AVAILABLE');
		# print("STATUSTITLE|✨\n");
	}

}

1;