use PerlTray;

use Win32::Service;
use Getopt::Long;

my $ssActive = 0;
my $pendingActivation = 0;
my $start = 0;
my $exit = 0;

use constant DEFAULT_TIMER_INTERVAL => 10;

# Dynamically create the popup menu based on Slimserver state
sub PopupMenu {
	my @menu;

	if ($ssActive) {
		push @menu, ["*Open SlimServer", "Execute 'SlimServer Web Interface.url'"];
		push @menu, ["--------"];
		push @menu, ["Stop SlimServer", \&stopSlimServer];
	}
	elsif ($pendingActivation) {
		push @menu, ["Starting SlimServer...", ""];
	}
	else {
		push @menu, ["*Start SlimServer", \&startSlimServer];
	}

	push @menu, ["--------"];
	push @menu, ["Go to Slim Devices Web Site", "Execute 'http://www.slimdevices.com'"];
	push @menu, ["E&xit", "exit"];
	
	return \@menu;
}

# Called when the tray application is invoked again. This can handle
# new startup parameters.
sub Singleton {
	# Had problems using Getopt::Long since @ARGV isn't set.
	# XXX There also seems to be a problem with arguments passed
	# in. $_[0] is not the first parameter, so we use $_[1].
	if (scalar(@_) > 1) {
		if ($_[1] eq '--start') {
			startSlimServer();
		}
		elsif ($_[1] eq '--exit') {
			exit;
		}
	}
}

# Display tooltip based on SS state
sub ToolTip {
	if ($pendingActivation) {
		return "SlimServer Starting";
	}

	if ($ssActive) {
		return "SlimServer Running";
	}
   
	return "SlimServer Stopped";
}

# The regular (heartbeat) timer that checks the state of SlimServer
# and modifies state variables.
sub Timer {
	my $wasPending = $pendingActivation;

	checkSSActive();

	if ($pendingActivation) {
		SetAnimation(DEFAULT_TIMER_INTERVAL * 1000, 1000, "SlimServer", "SlimServerOff");
	}
	# If we were waiting for SS to start before this check,
	# show the SS home page.
	# XXX Need to find actual HTTP port in prefs.
	elsif ($wasPending && $ssActive) {
		Execute("SlimServer Web Interface.url");
	}
}

# The one-time startup timer, since there are things we can't do
# at Perl initialization.
sub checkAndStart {
	SetTimer(0, \&checkAndStart);

	exit if ($exit);

	checkSSActive();
	
	if ($ssActive) {
		SetIcon("SlimServer");
	}
	else {
		SetIcon("SlimServerOff");
	}

	if ($start) {
		if (!$ssActive) {
			startSlimServer();
		}
		else {
			Execute("http://localhost:9000");
		}
		$start = 0;
	}
}


sub checkSSActive {
	my %status;

	# We use the Win32::Service package to see if the service
	# is still active. If we wanted the tray app to work with
	# Slimserver running as an application, we could attempt to
	# connect to the CLI port, e.g.:
	#   $sock = IO::Socket::INET->new(PeerAddr => 'localhost',
	#								  PeerPort => 9090,
	#								  Proto => 'tcp',
	#								  Reuse => 1,
	#								  Timeout => 9);

	Win32::Service::GetStatus('', 'slimsvc', \%status);

	if ($status{'CurrentState'} == 0x04) {
		SetIcon("SlimServer");
		$ssActive = 1;
		$pendingActivation = 0;
	}
	else {
		SetIcon("SlimServerOff");
		$ssActive = 0;
	}
}

sub startSlimServer {
	unless ($ssActive) {
		Balloon("Starting SlimServer...", "SlimServer", "", 1);
		SetAnimation(DEFAULT_TIMER_INTERVAL * 1000, 1000, "SlimServer", "SlimServerOff");
	}

	Win32::Service::StartService('', 'slimsvc');

	$pendingActivation = 1;
}

sub stopSlimServer {
	if ($ssActive) {
		Balloon("Stopping SlimServer...", "SlimServer", "", 1);
	}

	Win32::Service::StopService('', 'slimsvc');

	$ssActive = 0;
}

GetOptions('start' => \$start,
		   'exit' => \$exit);

# Checking for existence & launching of SS in a timer, since it
# fails if done during Perl initialization.
SetTimer(":1", \&checkAndStart);

# This is our regular timer which continually checks for existence of
# SS. We could have combined the two timers, but changing the
# frequency of the timer proved problematic.
SetTimer(":" . DEFAULT_TIMER_INTERVAL);

__END__

# Local Variables:
# tab-width:4
# indent-tabs-mode:t
# End:
