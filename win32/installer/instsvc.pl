#!/usr/bin/perl -w
use Win32::Daemon;

my $script = shift @ARGV || die 'need path to script';

my %ServiceConfig = (
	name => "squeezesvc",
	display => "Logitech Media Server",
	path => $^X,
	user => '',
	passwd => '',
	parameters => "\"$script\" --daemon",
	description => "Logitech Media Server - streaming media server",
);

if ( Win32::Daemon::CreateService ( \%ServiceConfig ) ) {
	print "The '$ServiceConfig{display}' service was successfully installed.\n";
}
else {
	print "Failed to add '$ServiceConfig{display}' service\n";
	print "Error: " . Win32::FormatMessage( Win32::Daemon::GetLastError() ), "\n";
}
