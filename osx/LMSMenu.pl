#!./bin/perl -Iserver/CPAN

use strict;

use Encode qw(decode_utf8);
use File::Spec::Functions qw(catfile);
use IO::Socket::INET;
use JSON::PP;
use Text::Unidecode;

my $http_port;

binmode(STDOUT, ":utf8");
my $STRINGS = decode_json(do {
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
	my $token = shift;
	my $string = $STRINGS->{$token}->{$lang} || $STRINGS->{$token}->{EN};
	print "$string\n";
}

sub getMenuItem {
	my $token = join(' ', @ARGV);
	# I've spent hours trying to do without Text::Unidecode, but have failed misearably.
	# There's an encoding issue somewhere between Platypus and Perl.
	$token = unidecode(decode_utf8($token));

	while (my ($tokenId, $details) = each %$STRINGS) {
		foreach my $value (grep { !ref $_ } values %$details) {
			return $tokenId if unidecode($value) eq $token;
		}
	}

	return "UNKNOWN ($token)";
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
	print("$http_port\n");
}
else {
	printMenuItem('START_SERVICE');
}



1;