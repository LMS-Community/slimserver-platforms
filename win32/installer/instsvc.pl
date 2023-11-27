#!/usr/bin/perl -w
use Win32::Daemon;

my ($script, $username, $password) = splice(@ARGV, 0, 3);

if (!$script) {
	die 'need path to script';
}
elsif (!($username && $password)) {
	$username = $password = '';
}
elsif ($username && $username !~ /^\./) {
	$username = ".\\$username";
}

my $arguments = join(' ', @ARGV);

my %ServiceConfig = (
	name => "squeezesvc",
	display => "Logitech Media Server",
	path => $^X,
	user => $username,
	password => $password,
	parameters => "\"$script\" --daemon $arguments",
	description => "Logitech Media Server - streaming media server",
);

if ( Win32::Daemon::CreateService ( \%ServiceConfig ) ) {
	print "The '$ServiceConfig{display}' service was successfully installed.\n";
}
else {
	print "Failed to add '$ServiceConfig{display}' service\n";
	print "Error: " . Win32::FormatMessage( Win32::Daemon::GetLastError() ), "\n";
}
