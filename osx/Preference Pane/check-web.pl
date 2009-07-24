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
	$ENV{HOME} . '/Library/Application Support/Squeezebox',
	'/Library/Application Support/Squeezebox',
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

if ( !$httpport || check_port( '127.0.0.1', $httpport ) != 1 ) {
	print "0\n";
} else {
	print "$httpport\n";
}
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