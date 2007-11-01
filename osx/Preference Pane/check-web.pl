#!/usr/bin/perl
#
# This script finds SC's web port and checks if it's listening

use strict;

use File::Spec::Functions;
use IO::Socket::INET;

# How long to wait for the server to start
my $timeout  = shift || 60;
my $httpport;

my @dirs = (
	$ENV{HOME} . '/Library/Application Support/SqueezeCenter',
	'/Library/Application Support/SqueezeCenter',
);

DIRS:
for my $dir ( @dirs ) {
	open my $prefs, '<', catfile( $dir, 'server.prefs' ) or next;
	while ( <$prefs> ) {
		if ( /^httpport: (\d+)/ ) {
			$httpport = $1;
			last;
		}
	}
	close $prefs;
	last if $httpport;
}

if ( !$httpport ) {
	die "ERROR: Cannot find server.prefs file\n";
}

my $time = 0;

while ( check_port( '127.0.0.1', $httpport ) != 1 ) {
	sleep 1;
	if ( $time++ > $timeout ) {
		die "ERROR: Server failed to start in $timeout seconds\n";
	}
}

print "$httpport\n";
exit;

sub check_port {
	my ( $host, $port ) = @_;
	
	my $remote = IO::Socket::INET->new(
		Proto    => 'tcp',
		PeerAddr => $host,
		PeerPort => $port,
	);
	
	if ( $remote ) {
		close $remote;
		return 1;
	}
	
	return;
}