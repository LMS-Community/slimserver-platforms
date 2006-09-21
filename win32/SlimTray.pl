# $Id$
# 
# SlimTray.exe controls the starting & stopping of the slimsvc Windows Service.
#
# If the service is not installed, we'll install it first.
#
# This program relies on Win32::Daemon, which is not part of CPAN.
# http://www.roth.net/perl/Daemon/

use strict;
use PerlTray;

use Cwd qw(cwd);
use File::Spec;
use Win32;
use Win32::Daemon;
use Win32::Process;
use Win32::Registry;
use Win32::Service;
use Getopt::Long;

my $ssActive = 0;
my $pendingActivation = 0;
my $start = 0;
my $exit = 0;

my $serviceName = 'slimsvc';

use constant DEFAULT_TIMER_INTERVAL => 10;

# Dynamically create the popup menu based on Slimserver state
sub PopupMenu {
	my @menu = ();

	my ($path, $type) = exePathAndStartupType();

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

	my $autoString  = 'Automatically Start';

	# We can't modify the service while it's running
	# So show a grayed out menu.
	my $setManual = undef;
	my $setAuto   = undef;

	if (!$ssActive && !$pendingActivation) {

		$setManual = \&setServiceManual;
		$setAuto   = \&setServiceAuto;
	}

	if ($type) {
		push @menu, ["v $autoString", $setManual, 1];
	}
	else {
		push @menu, ["_ $autoString", $setAuto, undef];
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

	} elsif ($wasPending && $ssActive) {

		# If we were waiting for SS to start before this check,
		# show the SS home page.
		# XXX Need to find actual HTTP port in prefs.
		Execute("SlimServer Web Interface.url");
	}
}

# The one-time startup timer, since there are things we can't do
# at Perl initialization.
sub checkAndStart {
	SetTimer(0, \&checkAndStart);

	exit if ($exit);

	# Install the service if it isn't already.
	my %status = ();

	Win32::Service::GetStatus('', $serviceName, \%status);

	if (scalar keys %status == 0) {

		installService();
	}

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
	my %status = ();

	# We use the Win32::Service package to see if the service
	# is still active. If we wanted the tray app to work with
	# Slimserver running as an application, we could attempt to
	# connect to the CLI port, e.g.:
	#   $sock = IO::Socket::INET->new(PeerAddr => 'localhost',
	#	PeerPort => 9090,
	#	Proto => 'tcp',
	#	Reuse => 1,
	#	Timeout => 9);

	Win32::Service::GetStatus('', $serviceName, \%status);

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

	if (!Win32::Service::StartService('', $serviceName)) {

		MessageBox("Starting SlimServer Service Failed. Please see the Event Viewer & Contact Support", "SlimServer", MB_OK | MB_ICONERROR);

		$pendingActivation = 0;
		$ssActive = 0;

	} elsif (!$ssActive) {

		Balloon("Starting SlimServer...", "SlimServer", "", 1);
		SetAnimation(DEFAULT_TIMER_INTERVAL * 1000, 1000, "SlimServer", "SlimServerOff");

		$pendingActivation = 1;
	}
}

sub stopSlimServer {

	if (!Win32::Service::StopService('', $serviceName)) {

		MessageBox("Stopping SlimServer Service Failed. Please see the Event Viewer & Contact Support", "SlimServer", MB_OK | MB_ICONERROR);

	} elsif ($ssActive) {

		Balloon("Stopping SlimServer...", "SlimServer", "", 1);
	}

	$ssActive = 0;
}

sub exePathAndStartupType {

	my ($resobj, %keys);

	my $root = "SYSTEM\\CurrentControlSet\\Services\\$serviceName";

	if ($main::HKEY_LOCAL_MACHINE->Open($root, $resobj)) {

		$resobj->GetValues(\%keys);

		if (!scalar %keys) {
			return ();
		}

		# Start of 2 is auto, 3 is manual.
		my $exe  = $keys{'ImagePath'}->[2];
		my $auto = $keys{'Start'}->[2] == 3 ? 0 : 1;

		return ($exe, $auto);
	}

	return ();
}

sub setServiceAuto {

	_configureService(SERVICE_AUTO_START);
}

sub setServiceManual {

	_configureService(SERVICE_DEMAND_START);
}

sub _configureService {
	my $type = shift;

	Win32::Daemon::ConfigureService({
		'machine'     => '',
		'name'        => $serviceName,
		'start_type'  => $type,
	});
}

sub installService {
	my $type = shift || SERVICE_DEMAND_START;

	my $exe  = File::Spec->catdir(cwd(), 'server', 'slim.exe');

	if (!-f $exe) {

		$exe = File::Spec->catdir('C:\Program Files', 'SlimServer', 'server');
	}

	Win32::Daemon::CreateService({
		'machine'     => '',
		'name'        => $serviceName,
		'display'     => 'SlimServer',
		'description' => "Slim Devices' SlimServer Music Server",
		'path'        => $exe,
		'start_type'  => $type,
	});
}

sub runBackground {
	my @args = @_;

	$args[0] = Win32::GetShortPathName($args[0]);

	my $os_obj = 0;

	Win32::Process::Create(
		$os_obj,
		$args[0],
		"@args",
		0,
		CREATE_NO_WINDOW | NORMAL_PRIORITY_CLASS,
		'.'
	);
}

*PerlTray::ToolTip = \&ToolTip;

GetOptions(
	'start' => \$start,
	'exit'  => \$exit,
);

# Checking for existence & launching of SS in a timer, since it
# fails if done during Perl initialization.
SetTimer(":1", \&checkAndStart);

# This is our regular timer which continually checks for existence of
# SS. We could have combined the two timers, but changing the
# frequency of the timer proved problematic.
SetTimer(":" . DEFAULT_TIMER_INTERVAL);

__END__
