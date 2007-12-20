# $Id$
# 
# SqueezeTray.exe controls the starting & stopping of the SqueezeCenter application
#
# This program relies on Win32::Daemon, which is not part of CPAN.
# http://www.roth.net/perl/Daemon/

use strict;
use PerlTray;

use Cwd qw(cwd);
use File::Spec;
use Getopt::Long;
use Socket;
use Encode;

use Win32 qw(GetOSName);
use Win32::Locale;
use Win32::Process qw(DETACHED_PROCESS CREATE_NO_WINDOW NORMAL_PRIORITY_CLASS);
use Win32::Process::List;
use Win32::TieRegistry ('Delimiter' => '/');
use Win32::Service;

my $timerSecs      = 10;
my $scActive       = 0;
my $starting       = 0;
my $processObj     = 0;
my $checkHTTP      = 0;
my $lastHTTPPort   = 0;

my %strings        = ();

# Passed on the command line by Getopt::Long
my $cliStart       = 0;
my $cliExit        = 0;
my $cliInstall     = 0;
my $cliUninstall   = 0;

my $registryKey    = 'CUser/Software/Logitech/SqueezeCenter';

# Migrate SlimServer settings
if (my $ssRegistryKey  = 'CUser/Software/SlimDevices/SlimServer') {
	if (defined $Registry->{"$ssRegistryKey/StartAtLogin"}) {
		$Registry->{"$registryKey/StartAtLogin"} = $Registry->{"$ssRegistryKey/StartAtLogin"};
		delete $Registry->{"$ssRegistryKey/StartAtLogin"};
	}

	delete $Registry->{"$ssRegistryKey/"};
	delete $Registry->{'CUser/Software/SlimDevices/'};
}

my $atLogin        = $Registry->{"$registryKey/StartAtLogin"};

my $serviceName    = 'squeezesvc';

my $appExe         = File::Spec->catdir(installDir(), 'server', 'squeezecenter.exe');
my $serverUrl      = File::Spec->catdir(writableDir(), "SqueezeCenter Web Interface.url");
my $serverPrefFile = File::Spec->catdir(writableDir(), 'prefs', 'server.prefs');
my $language       = getPref('language') || 'EN';

# Dynamically create the popup menu based on SqueezeCenter state
sub PopupMenu {
	my @menu = ();

	my $type = startupType(); # = none, login or auto

	if ($type eq 'auto') {
		push @menu, [sprintf('*%s', string('OPEN_SQUEEZECENTER')), $scActive ? \&openSqueezeCenter : undef];
	}
	elsif ($scActive) {
		push @menu, [sprintf('*%s', string('OPEN_SQUEEZECENTER')), \&openSqueezeCenter];
		push @menu, ["--------"];
		push @menu, [string('STOP_SQUEEZECENTER'), \&stopSqueezeCenter];
	}
	elsif ($starting) {
		push @menu, [string('STARTING_SQUEEZECENTER'), ""];
	}
	else {
		push @menu, [sprintf('*%s', string('START_SQUEEZECENTER')), \&startSqueezeCenter];
	}

	my $appString     = string('RUN_AT_LOGIN');

	my $setNone  = sub { setStartupType('none') };
	my $setLogin = sub { setStartupType('login') };

	if ($type eq 'login') {
		push @menu, ["v $appString", $setNone, 1];
	}
	elsif ($type ne 'auto') {
		push @menu, ["_ $appString", $setLogin, undef];
	}

	push @menu, ["--------"];
	push @menu, [string('GO_TO_WEBSITE'), "Execute 'http://www.slimdevices.com'"];
	push @menu, [string('EXIT'), "exit"];

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

			$cliStart = 1;

			if (!$scActive && !$starting) {

				startSqueezeCenter();
			}

			if ($scActive) {

				openSqueezeCenter();

			} else {

				$checkHTTP = 1;
			}

		} elsif ($_[1] eq '--exit') {

			if (scalar(@_) > 2 && $_[2] eq '--uninstall') {
				uninstall();
			}

			exit;
		}
	}
}

# double click on tray icon - attempt to avoid accidental call of exit
sub DoubleClick {

	if ($scActive) {

		openSqueezeCenter();

	} else {

		DisplayMenu();
	}
}

# Display tooltip based on SS state
sub ToolTip {
	my $state;

	# use English if HE is selected on western systems, as these can't handle the Hebrew tooltip
	my $lang = ($language eq 'HE' && Win32::Locale::get_language() ne 'he' ? 'EN' : $language);

 	if ($starting) {
		$state = string('SQUEEZECENTER_STARTING', $lang);
 	}
 
 	elsif ($scActive) {
		$state = string('SQUEEZECENTER_RUNNING', $lang);
 	}
    
 	else {
		$state = string('SQUEEZECENTER_STOPPED', $lang);
 	}
 
	# try to prevent intermittent "Unknown encoding 'cp1250' at SqueezeTray.pl line 170" crasher
	eval "$state = encode($lang eq 'HE' ? 'cp1255' : 'cp1250', $state);";

	return $state;
}

# The regular (heartbeat) timer that checks the state of SqueezeCenter
# and modifies state variables.
sub Timer {

	checkSCActive();

	if ($starting) {

		SetAnimation($timerSecs * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	} elsif ($scActive && $checkHTTP && checkForHTTP()) {

		$checkHTTP = 0;
		openSqueezeCenter() if ($cliStart || $cliInstall)
	}
}

# The one-time startup timer, since there are things we can't do
# at Perl initialization.
sub checkAndStart {

	# Kill the timer, we only want to run once.
	SetTimer(0, \&checkAndStart);

	if ($cliUninstall) {
		uninstall();
	}

	if ($cliExit) {
		exit;
	}

	if ($cliInstall) {
		# preset $atLogin if it isn't defined yet
		$atLogin = 1 if ($atLogin ne '0' && $atLogin ne '1');

		$Registry->{'CUser/Software/'}->{'Logitech/'} = {
			'SqueezeCenter/' => {
				'/StartAtLogin' => $atLogin
			},
		};

		checkSCActive();

		$checkHTTP = 1; # check server and open browser when it comes up
	}

	my $startupType = startupType();

	# If we're set to Start at Login, do it, but only if the process isn't
	# already running.
	if (processID() == -1 && $startupType eq 'login') {

		startSqueezeCenter();
	}

	# Now see if the app happens to be up already.
	checkSCActive();

	# Handle the command line --start flag.
	if ($cliStart) {

		if (!$scActive && !$starting) {

			startSqueezeCenter();
		}

		if ($scActive) {

			openSqueezeCenter();

		} else {

			$checkHTTP = 1;
		}

	}
}

sub checkSCActive {
	my $state = 'stopped';

	if (startupTypeIsService()) {

		my %status = ();

		Win32::Service::GetStatus('', $serviceName, \%status);

		if ($status{'CurrentState'} == 0x04) {

			$state = 'running';
		}

		if ($status{'CurrentState'} == 0x02) {

			$starting = 1;
		}

		if ($status{'CurrentState'} == 0x01) {

			$starting = 0;
		}

	} else {

		if (processID() != -1) {

			$state = 'running';
		}

	}

	if ($state eq 'running' && $checkHTTP && !checkForHTTP()) {

		$starting = 1;
		$scActive = 0;

	}
	elsif ($state eq 'running') {

		SetIcon("SqueezeCenter");
		$scActive = 1;
		$starting = 0;

	} else {

		SetIcon("SqueezeCenterOff");
		$scActive = 0;
	}
}

sub startSqueezeCenter {
	return if startupTypeIsService();

	runBackground($appExe);

	if (!$scActive) {

		Balloon(string('STARTING_SQUEEZECENTER'), "SqueezeCenter", "", 1);
		SetAnimation($timerSecs * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

		$checkHTTP = 1;
		$starting = 1;
	}
}

# Called from menu when SS is active
sub openSqueezeCenter {

	# Check HTTP first in case SqueezeCenter has changed the HTTP port while running
	checkForHTTP();	
	Execute($serverUrl);

	$cliStart = 0;
}

sub showErrorMessage {
	my $message = shift;

	MessageBox($message, "SqueezeCenter", MB_OK | MB_ICONERROR);
}

sub startupTypeIsService {
	return (startupType() eq 'auto');
}

# Determine how the user wants to start SqueezeCenter
sub startupType {
	my %services;

	Win32::Service::GetServices('', \%services);

	if (grep {$services{$_} =~ /$serviceName/} keys %services) {
		return 'auto';
	}

	if ($atLogin) {
		return 'login';
	}

	return 'none';
}

sub setStartupType {
	my $type = shift;

	if ($type !~ /^(?:login|none)$/) {

		return;
	}

	if ($type eq 'login') {

		$Registry->{"$registryKey/StartAtLogin"} = $atLogin = 1;

	} elsif ($type eq 'none') {

		$Registry->{"$registryKey/StartAtLogin"} = $atLogin = 0;
	}
}

# Return the SqueezeCenter install directory.
sub installDir {

	# Try and find it in the registry.
	# This is a system-wide registry key.
	my $swKey = $Registry->{"LMachine/Software/Logitech/SqueezeCenter/Path"};

	if (defined $swKey) {
		return $swKey;
	}

	# Otherwise look in the standard location.
	# search in legacy SlimServer folder, too
	my $installDir;
	PF: foreach my $programFolder ($ENV{ProgramFiles}, 'C:/Program Files') {
		foreach my $ourFolder ('SqueezeCenter', 'SlimServer') {

			$installDir = File::Spec->catdir($programFolder, $ourFolder);
			last PF if (-d $installDir);

		}
	}

	# If it's not there, use the current working directory.
	if (!-d $installDir) {

		$installDir = cwd();
	}

	return $installDir;
}

# Return directory for files which SqueezeCenter can save - i.e. location of prefs file
sub writableDir {

	my $swKey = $Registry->{'LMachine/Software/Microsoft/Windows/CurrentVersion/Explorer/Shell Folders/Common AppData'};

	if (defined $swKey) {
		return File::Spec->catdir($swKey, 'SqueezeCenter');
	}

	return File::Spec->catdir(installDir(), 'server');
}

# Read pref from the server preference file - lighter weight than loading YAML
sub getPref {
	my $pref = shift;
	my $prefFile = shift;
	
	if ($prefFile) {
		$prefFile = File::Spec->catdir(writableDir(), 'prefs', 'plugin', $prefFile);
	}
	else {
		$prefFile = $serverPrefFile;
	}

	my $ret;

	if (-r $prefFile) {

		if (open(PREF, $prefFile)) {

			while (<PREF>) {
				# read YAML (server) and old style prefs (installer)
				if (/^$pref(:| \=) (\w+)$/) {
					$ret = $2;
					last;
				}
			}

			close(PREF);
		}
	}

	return $ret;
}

sub checkForHTTP {
	my $httpPort = getPref('httpport') || 9000;

	if ($lastHTTPPort ne $httpPort) {

		updateSqueezeCenterWebInterface($httpPort);
		$lastHTTPPort = $httpPort
	}

	# Use low-level socket code. IO::Socket returns a 'Invalid Descriptor'
	# erorr. It also sucks more memory than it should.
	my $raddr = '127.0.0.1';
	my $rport = $httpPort;

	my $iaddr = inet_aton($raddr);
	my $paddr = sockaddr_in($rport, $iaddr);

	socket(SSERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'));

	if (connect(SSERVER, $paddr)) {

		close(SSERVER);
		return $httpPort;
	}

	return 0;
}

sub runBackground {
	my @args = @_;

	$args[0] = Win32::GetShortPathName($args[0]);

	Win32::Process::Create(
		$processObj,
		$args[0],
		"@args",
		0,
		DETACHED_PROCESS | CREATE_NO_WINDOW | NORMAL_PRIORITY_CLASS,
		'.'
	);
}

sub processID {

	my $p = Win32::Process::List->new;

	if ($p->IsError == 1) {

		showErrorMessage("ProcessID: an error occured: " . $p->GetErrorText . " ");
	}

	# Windows sometimes only displays squeez~1.exe or similar
	my $pid = ($p->GetProcessPid(qr/^squeez(ecenter|~\d).exe$/i))[1];

	return $pid if defined $pid;
	return -1;
}

# update SqueezeCenter Web Interface.url
#
#  One parameter the new port number

sub updateSqueezeCenterWebInterface {
	my $port = shift;

	if (open(URLFILE, ">:crlf", $serverUrl)) {

		print URLFILE "[InternetShortcut]\nURL=http://127.0.0.1:$port\n";
		close URLFILE;

	} else {

		showErrorMessage(sprintf('%s %s: %s', string('WRITE_FAILED', $serverUrl, $!)));
	}
}

sub stopSqueezeCenter {
	my $suppressMsg = shift;
	my $cliPort = getPref('cliport', 'cli.prefs') || 9090;

	# Use low-level socket code. IO::Socket returns a 'Invalid Descriptor'
	# erorr. It also sucks more memory than it should.
	my $raddr = '127.0.0.1';
	my $rport = $cliPort;

	my $iaddr = inet_aton($raddr);
	my $paddr = sockaddr_in($rport, $iaddr);

	socket(SSERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'));

	if (connect(SSERVER, $paddr)) {

		print SSERVER "stopserver\n", ;

		close(SSERVER);
	}

	elsif (!$suppressMsg) {

		showErrorMessage(string('STOP_FAILED'));

		return;
	}

	if ($scActive) {

		Balloon(string('STOPPING_SQUEEZECENTER'), "SqueezeCenter", "", 1);

		$scActive = 0;
	}
}


# attempt to stop SqueezeCenter and exit
sub uninstall {
	# Kill the timer, we don't want SC to be restarted
	SetTimer(0);

	stopSqueezeCenter(1);

	exit;
}

# return localised version of string token
sub string {
	my $name = shift;
	my $lang = shift || $language;

	$strings{ $name }->{ $lang } || $strings{ $name }->{'EN'} || "Bad string $name";
}

sub loadStrings {
	my $string     = '';
	my $language   = '';
	my $stringname = '';

	my $file = 'strings.txt';

	open(STRINGS, $file) || do {
		die "Couldn't open $file - FATAL!";
	};

	LINE: while (my $line = <STRINGS>) {

		chomp($line);
		
		next if $line =~ /^#/;
		next if $line !~ /\S/;

		if ($line =~ /^(\S+)$/) {

			$stringname = $1;
			$string = '';
			next LINE;

		} elsif ($line =~ /^\t(\S*)\t(.+)$/) {

			$language = uc($1);
			$string   = $2;

			$strings{$stringname}->{$language} = $string;
		}
	}

	close STRINGS;
}

*PerlTray::ToolTip = \&ToolTip;

GetOptions(
	'start'     => \$cliStart,
	'exit'      => \$cliExit,
	'install'   => \$cliInstall,
	'uninstall' => \$cliUninstall,
);

loadStrings();

# Checking for existence & launching of SS in a timer, since it
# fails if done during Perl initialization.
SetTimer(":1", \&checkAndStart);

# This is our regular timer which continually checks for existence of
# SS. We could have combined the two timers, but changing the
# frequency of the timer proved problematic.
SetTimer(":" . $timerSecs);
