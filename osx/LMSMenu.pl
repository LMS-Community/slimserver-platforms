#!/usr/bin/perl

use strict;
use utf8;

use Data::Dumper;
# use Digest::MD5 qw(md5_base64);
use Encode qw(encode_utf8 decode);
# use Encode qw(encode_utf8 decode_utf8 decode encode find_encoding from_to);
use File::Spec::Functions qw(catdir catfile);
use FindBin qw($Bin);
use IO::Socket::INET;
use JSON::PP;
use Text::Unidecode;

my $http_port;

my $STRINGS = {
	START_SERVICE => {
		DE => 'Dienst starten',
		EN => 'Start Service'
	},
	STOP_SERVICE => {
		DE => 'Dienst stoppen',
		EN => 'Stop Service'
	},
	OPEN_GUI => {
		DE => 'Web-Steuerung öffnen...',
		EN => 'Open Web Control...'
	},
	OPEN_SETTINGS => {
		DE => 'Einstellungen öffnen...',
		EN => 'Open Settings...'
	}
};

my $lang = uc(substr(`/usr/bin/defaults read -g AppleLocale` || 'EN', 0, 2));

$lang = 'DE';

use constant SERVER_RUNNING => `ps -axww | fgrep "slimserver.pl" | grep -v grep | cat`;
use constant PRODUCT_NAME => 'Squeezebox';
# use constant LOG_FOLDER => catdir($ENV{HOME}, 'Library', 'Logs', PRODUCT_NAME);
use constant PREFS_FILE => catfile($ENV{HOME}, 'Library', 'Application Support', PRODUCT_NAME, 'server.prefs');

sub getPort {
	$http_port = undef;
	if (-f PREFS_FILE) {
		open(FH, '<', PREFS_FILE) or return;

		while (<FH>) {
			if (/^httpport: (\d+)/) {
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
	my $token = shift;
	my $string = encode_utf8($STRINGS->{$token}->{$lang} || $STRINGS->{$token}->{EN});
	print "$string\n";
}

sub getMenuItem {
	my $token = join(' ', @ARGV);
	# for whatever reason I can't move decode() before this line, or inside _cleanupString()...
	$token = _cleanupString(decode('utf8', $token));

print $token;
	while (my ($tokenId, $details) = each %$STRINGS) {
		foreach my $value (grep { !ref $_ } values %$details) {
			print _cleanupString($value) . "\n";
			return $tokenId if _cleanupString($value) eq $token;
		}
	}

	return "UNKNOWN ($token)";
}

# there's an encoding issue somewhere between Platypus, the shell script and perl
# let's try to "normalize" the string here
sub _cleanupString {
	return Text::Unidecode::unidecode(shift);
}

getPort();

if (scalar @ARGV > 0) {
	my $item = getMenuItem();

	if ($item eq 'OPEN_GUI') {
		system("open http://localhost:$http_port/");
	}
	elsif ($item eq 'OPEN_SETTINGS') {
		system("open http://localhost:$http_port/settings/index.html");
	}
	else {
		print "ALERT:Selected Item...|$item\n";
	}

	exit;
}

if ($http_port) {
	printMenuItem('OPEN_GUI');
	printMenuItem('OPEN_SETTINGS');
	printMenuItem('STOP_SERVICE');
}
else {
	printMenuItem('START_SERVICE');
}



1;