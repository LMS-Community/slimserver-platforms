package LMSMenuAction;

use strict;

use Cwd;
use Encode qw(decode_utf8);
use File::Spec::Functions qw(catfile);
use Text::Unidecode;

my $http_port;

sub handleAction {
	($http_port) = @_;

	my $item = getMenuItem();

	if ($item eq 'OPEN_GUI') {
		system("open http://localhost:$http_port/");
	}
	elsif ($item eq 'OPEN_SETTINGS') {
		system("open http://localhost:$http_port/settings/index.html");
	}
	elsif ($item eq 'START_SERVICE') {
		# we're going to re-use a shell script which will be used elsewhere, too
		runScript('start-server.sh');
	}
	elsif ($item eq 'STOP_SERVICE') {
		runScript('stop-server.sh');
	}
	elsif ($item eq 'AUTOSTART_ON') {
		runScript('remove-launchitem.sh');
	}
	elsif ($item eq 'AUTOSTART_OFF') {
		runScript('create-launchitem.sh');
	}
	else {
		my $x = unidecode(join(' ', @ARGV));
		print "ALERT:Selected Item...|$item $x\n";
	}
}

sub runScript {
	system(catfile(cwd(), shift));
}

sub getMenuItem {
	my $token = join(' ', @ARGV);
	# I've spent hours trying to do without Text::Unidecode, but have failed misearably.
	# There's an encoding issue somewhere between Platypus and Perl.
	$token = unidecode(decode_utf8($token));

	while (my ($tokenId, $details) = each %{$main::STRINGS}) {
		foreach my $value (grep { !ref $_ } values %$details) {
			return $tokenId if unidecode($value) eq $token;
		}
	}

	return "UNKNOWN ($token)";
}

1;