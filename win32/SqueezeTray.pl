# $Id$
# 
# SqueezeTray.exe controls the starting & stopping of the SqueezeCenter application

use strict;
use PerlTray;

use File::Spec::Functions qw(catdir);
use Getopt::Long;
use Socket;
use Encode;

use Win32::Locale;

use constant SLIM_SERVICE => 0;
use constant SCANNER => 0;
use constant TIMERSECS => 10;

use Slim::Utils::ServiceManager;
use Slim::Utils::Light;

# Passed on the command line by Getopt::Long
my $cliStart       = 0;
my $cliExit        = 0;
my $cliInstall     = 0;
my $cliUninstall   = 0;

my $language       = getPref('language') || 'EN';
my $svcMgr         = Slim::Utils::ServiceManager->new();

# Dynamically create the popup menu based on SqueezeCenter state
sub PopupMenu {
	my @menu = ();
	
	my $type = $svcMgr->getStartupType();
	my $state = $svcMgr->getServiceState();

	if ($type == SC_STARTUP_TYPE_SERVICE) {
		push @menu, [sprintf('*%s', string('OPEN_SQUEEZECENTER')), $state == SC_STATE_RUNNING ? \&openSqueezeCenter : undef];
		push @menu, ["--------"];
		push @menu, [string('STOP_SQUEEZECENTER'), $state == SC_STATE_RUNNING ? \&stopSqueezeCenter : undef];
	}
	elsif ($state == SC_STATE_RUNNING) {
		push @menu, [sprintf('*%s', string('OPEN_SQUEEZECENTER')), \&openSqueezeCenter];
		push @menu, ["--------"];
		push @menu, [string('STOP_SQUEEZECENTER'), \&stopSqueezeCenter];
	}
	elsif ($svcMgr->getServiceState() == SC_STATE_STARTING) {
		push @menu, [string('STARTING_SQUEEZECENTER'), ""];
	}
	else {
		push @menu, [sprintf('*%s', string('START_SQUEEZECENTER')), \&startSqueezeCenter];
	}

	my $appString = string('RUN_AT_LOGIN');

	my $setNone  = sub { $svcMgr->setStartAtLogin(0) };
	my $setLogin = sub { $svcMgr->setStartAtLogin(1) };

	if ($type == SC_STARTUP_TYPE_LOGIN) {
		push @menu, ["v $appString", $setNone, 1];
	}
	elsif ($type == SC_STARTUP_TYPE_SERVICE) {
		push @menu, ["_ $appString", $setLogin, undef];
	}

	if ( my $installer = _getUpdateInstaller() ) {
		push @menu, ["--------"];
		push @menu, [string('INSTALL_UPDATE'), sub {
			system("\"$installer\" /silent");
		}];	
	}

	push @menu, ["--------"];
	push @menu, [string('CLEANUP'), \&launchCleanup];

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

			if ($svcMgr->getServiceState() == SC_STATE_STOPPED) {

				startSqueezeCenter();
			}

			if ($svcMgr->getServiceState() == SC_STATE_RUNNING) {

				openSqueezeCenter();

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

	if ($svcMgr->getServiceState() == SC_STATE_RUNNING) {

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

 	if ($svcMgr->getServiceState() == SC_STATE_STARTING) {
		$state = string('SQUEEZECENTER_STARTING', $lang);
 	}
 
 	elsif ($svcMgr->getServiceState() == SC_STATE_RUNNING) {
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

	my $state = $svcMgr->checkServiceState();

	if ($state == SC_STATE_STARTING) {

		SetAnimation(TIMERSECS * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	} elsif ($state == SC_STATE_RUNNING && ($cliStart || $cliInstall)) {

		openSqueezeCenter();
	}

	checkSCActive();
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
		$svcMgr->initStartupType();

		checkSCActive();
	}

	# If we're set to Start at Login, do it, but only if the process isn't
	# already running.
	if (processID() == -1 && $svcMgr->getStartupType() == SC_STARTUP_TYPE_LOGIN) {

		startSqueezeCenter();
	}

	# Now see if the app happens to be up already.
	checkSCActive();

	# Handle the command line --start flag.
	if ($cliStart) {

		my $state = $svcMgr->getServiceState();

		if ($state == SC_STATE_STOPPED) {

			startSqueezeCenter();
		}

		if ($state == SC_STATE_RUNNING) {

			openSqueezeCenter();

		}

	}
}

sub checkSCActive {
	my $update = shift;
	
	$svcMgr->checkServiceState();
	
	my $state = $svcMgr->getServiceState();

	if ($state == SC_STATE_RUNNING) {
		SetIcon("SqueezeCenter");
	}
	else {
		SetIcon("SqueezeCenterOff");
	}
}

# see whether SC has downloaded an update version
sub checkForUpdate {
	if ( _getUpdateInstaller() ) {
		Balloon(string('UPDATE_AVAILABLE'), "SqueezeCenter", "", 1);
		
		# once the balloon is shown, only poll every 6 hours
		SetTimer('6:00:00', \&checkForUpdate);
	}
}

sub _getUpdateInstaller {
	my $installer = getPref('updateInstaller');
	return $installer if ($installer && -r $installer);	
}

sub startSqueezeCenter {
	$svcMgr->start();

	if ($svcMgr->getServiceState() != SC_STATE_STARTING) {

		Balloon(string('STARTING_SQUEEZECENTER'), "SqueezeCenter", "", 1);
		SetAnimation(TIMERSECS * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	}
}

# Called from menu when SS is active
sub openSqueezeCenter {

	# Check HTTP first in case SqueezeCenter has changed the HTTP port while running
	my $serverUrl = $svcMgr->checkForHTTP();	
	Execute($serverUrl) if $serverUrl;

	$cliStart = 0;
}

sub showErrorMessage {
	my $message = shift;

	MessageBox($message, "SqueezeCenter", MB_OK | MB_ICONERROR);
}

sub processID {
	my $pid = $svcMgr->getProcessID();

	# if there was an error, getProcessID() will return the error mesasage
	if ($pid =~ /[^\d\-]/) {
		showErrorMessage("ProcessID: an error occured: $pid");
		return -1;
	}

	return $pid if defined $pid;
	return -1;
}

sub launchCleanup {

	# ask whether the user really wants to stop SC to do the cleanup
	if (sendCLICommand('serverstatus')) {
		if (MessageBox(
			string('CLEANUP_ARE_YOU_SURE'),
			string('CLEANUP_TITLE'),
			MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2
		) != IDYES) {
	
			return			
		}

		stopScanner();
	
		# let's give the scanner a few seconds to be closed before shutting down SC
		sleep 5;
	
		stopSqueezeCenter();
	}
	
	Execute(catdir($svcMgr->installDir(), 'server', 'cleanup.exe'));
}

sub stopSqueezeCenter {
	my $suppressMsg = shift;

	unless (sendCLICommand('stopserver') || $suppressMsg) {

		showErrorMessage(string('STOP_FAILED'));

		return;
	}

	if ($svcMgr->getServiceState() == SC_STATE_RUNNING) {

		Balloon(string('STOPPING_SQUEEZECENTER'), "SqueezeCenter", "", 1);

	}
}

sub stopScanner {
	sendCLICommand('abortscan');
}

sub sendCLICommand {
	my $cmd = shift;
	my $cliPort = getPref('cliport', 'cli.prefs') || 9090;

	# Use low-level socket code. IO::Socket returns a 'Invalid Descriptor'
	# erorr. It also sucks more memory than it should.
	my $raddr = '127.0.0.1';
	my $rport = $cliPort;

	my $iaddr = inet_aton($raddr);
	my $paddr = sockaddr_in($rport, $iaddr);

	socket(SSERVER, PF_INET, SOCK_STREAM, getprotobyname('tcp'));

	if (connect(SSERVER, $paddr)) {

		print SSERVER "$cmd\n", ;

		close(SSERVER);
		
		return 1;
	}

	return 0;
}

# attempt to stop SqueezeCenter and exit
sub uninstall {
	# Kill the timer, we don't want SC to be restarted
	SetTimer(0);

	# stop the scanner _before_ SC, as it's talking to SC using the CLI
	stopScanner();

	# let's give the scanner a few seconds to be closed before shutting down SC
	sleep 5;

	stopSqueezeCenter(1);

	exit;
}

*PerlTray::ToolTip = \&ToolTip;

GetOptions(
	'start'     => \$cliStart,
	'exit'      => \$cliExit,
	'install'   => \$cliInstall,
	'uninstall' => \$cliUninstall,
);

# Checking for existence & launching of SS in a timer, since it
# fails if done during Perl initialization.
SetTimer(":1", \&checkAndStart);

# This is our update checker timer
SetTimer(":2", \&checkForUpdate);

# This is our regular timer which continually checks for existence of
# SS. We could have combined the two timers, but changing the
# frequency of the timer proved problematic.
SetTimer(":" . TIMERSECS);
