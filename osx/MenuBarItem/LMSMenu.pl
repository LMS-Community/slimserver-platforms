#!./bin/perl -Iserver/CPAN -Iserver -I.

use strict;

use File::Spec::Functions qw(catfile);
use IO::Socket::INET;
use JSON::PP;

use LMSMenuAction;

my $http_port;

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
	$http_port = undef;
	if (-f PREFS_FILE) {
		open(FH, '<', PREFS_FILE) or return;

		while (<FH>) {
			if (/^httpport: ['"]?(\d+)['"]?/) {
				my $port = $1;
				my $remote = IO::Socket::INET->new(
					Proto    => 'tcp',
					PeerAddr => '127.0.0.1',
					PeerPort => $port,
				);

				if ( $remote ) {
					close $remote;
					$http_port = $port;
				}

				last;
			}
		}

		close FH;
	}

	return $http_port;
}

sub printMenuItem {
	my ($token, $icon) = @_;
	$icon = "MENUITEMICON|$icon|" if $icon;

	my $string = $STRINGS->{$token}->{$lang} || $STRINGS->{$token}->{EN};
	print "$icon$string\n";
}

getPort();

if (scalar @ARGV > 0) {
	LMSMenuAction::handleAction($http_port);
}
else {
	my $autoStartItem = -f catfile($ENV{HOME}, 'Library', 'LaunchAgents', 'Squeezebox.plist')
		? 'AUTOSTART_ON'
		: 'AUTOSTART_OFF';

	if ($http_port) {
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
}


1;