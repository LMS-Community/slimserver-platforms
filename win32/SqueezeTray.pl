# Logitech Media Server Copyright 2001-2011 Logitech.
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License, 
# version 2.

# SqueezeTray.exe controls the starting & stopping of the server application

use strict;
use PerlTray;

use File::Spec::Functions qw(catdir);
use Getopt::Long;
use Socket;
use Encode;

use Win32::Locale;
use Win32::Process;
use Win32::Process::List;

use Win32::TieRegistry ('Delimiter' => '/');

use constant SB_USER_REGISTRY_KEY => 'CUser/Software/Logitech/Squeezebox';

use constant SLIM_SERVICE => 0;
use constant SCANNER      => 0;
use constant ISWINDOWS    => 1;
use constant TIMERSECS    => 10;
use constant INFOLOG      => 0;

use Slim::Utils::ServiceManager;
use Slim::Utils::Light;
use Slim::Utils::OSDetect;

Slim::Utils::OSDetect::init();

# Passed on the command line by Getopt::Long
my $cliStart       = 0;
my $cliExit        = 0;
my $cliInstall     = 0;
my $cliUninstall   = 0;

my $svcMgr         = Slim::Utils::ServiceManager->new();
my $os             = Slim::Utils::OSDetect::getOS();
my $language       = getPref('language') || $os->getSystemLanguage() || 'EN';

my $restartFlag    = catdir(getPref('cachedir') || $os->dirsFor('cache'), 'restart.txt');
my $controlPanel   = catdir(scalar($os->dirsFor('base')), 'server', 'squeezeboxcp.exe');

${^WIN32_SLOPPY_STAT} = 1;

# Dynamically create the popup menu based on the server's state
sub PopupMenu {
	my @menu = ();
	
	my $type = $svcMgr->getStartupType();
	my $state = $svcMgr->getServiceState();

	push @menu, [($Registry->{SB_USER_REGISTRY_KEY . '/DefaultToWebUI'} ? '' : '*') . string('OPEN_CONTROLPANEL'), \&openControlPanel];
	push @menu, [($Registry->{SB_USER_REGISTRY_KEY . '/DefaultToWebUI'} ? '*' : '') . string('OPEN_SQUEEZEBOX_SERVER'), $state == SC_STATE_RUNNING ? \&openServer : undef];

	if ( my $installer = Slim::Utils::Light->checkForUpdate() ) {
		push @menu, [string('INSTALL_UPDATE'), \&updateServerSoftware];	
	}
	push @menu, ["--------"];

	if ($type == SC_STARTUP_TYPE_SERVICE) {
		push @menu, [string('STOP_SQUEEZEBOX_SERVER'), $state == SC_STATE_RUNNING ? \&stopServer : undef];
	}
	elsif ($state == SC_STATE_RUNNING) {
		push @menu, [string('STOP_SQUEEZEBOX_SERVER'), \&stopServer];
	}
	elsif ($svcMgr->getServiceState() == SC_STATE_STARTING) {
		push @menu, [string('STARTING_SQUEEZEBOX_SERVER'), ""];
	}
	else {
		push @menu, [string('START_SQUEEZEBOX_SERVER'), \&startServer];
	}

	my $appString = string('RUN_AT_LOGIN');

	my $setNone  = sub { $svcMgr->setStartupType(SC_STARTUP_TYPE_NONE) };
	my $setLogin = sub { $svcMgr->setStartupType(SC_STARTUP_TYPE_LOGIN) };

	if ($type == SC_STARTUP_TYPE_LOGIN) {
		push @menu, ["v $appString", $setNone, 1];
	}
	elsif ($type == SC_STARTUP_TYPE_NONE) {
		push @menu, ["_ $appString", $setLogin, undef];
	}

	push @menu, ["--------"];
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

				startServer();
			}

			if ($Registry->{SB_USER_REGISTRY_KEY . '/DefaultToWebUI'}) {
				openServer();
			}
			else {
				openControlPanel();
			}

		} elsif ($_[1] eq '--exit') {

			if (scalar(@_) > 2 && $_[2] eq '--uninstall') {
				uninstall();
			}

			exit;
		}
	}
}

sub DoubleClick {
	if ($Registry->{SB_USER_REGISTRY_KEY . '/DefaultToWebUI'}) {

		if ($svcMgr->isRunning()) {
			openServer();
		}
		else {
			DisplayMenu();
		}

	}

	else {
		openControlPanel();
	}
}

# Display tooltip based on SS state
sub ToolTip {
	my $state = $svcMgr->getServiceState();

	# use English if HE is selected on western systems, as these can't handle the Hebrew tooltip
	my $lang = ($language eq 'HE' && Win32::Locale::get_language() ne 'he' ? 'EN' : $language);

 	if ($state == SC_STATE_STARTING) {
		$state = string('SQUEEZEBOX_SERVER_STARTING', $lang);
 	}
 
 	elsif ($state == SC_STATE_RUNNING) {
		$state = string('SQUEEZEBOX_SERVER_RUNNING', $lang);
 	}
    
 	else {
		$state = string('SQUEEZEBOX_SERVER_STOPPED', $lang);
 	}
 
	# try to prevent intermittent "Unknown encoding 'cp1250' at SqueezeTray.pl line 170" crasher
	eval "$state = encode($lang eq 'HE' ? 'cp1255' : 'cp1250', $state);";

	return $state;
}

# The regular (heartbeat) timer that checks the state of the server
# and modifies state variables.
sub Timer {

	my $state = $svcMgr->checkServiceState();

	if ($state == SC_STATE_STARTING) {

		SetAnimation(TIMERSECS * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	}
	
	checkSCActive();
}

# The one-time startup timer, since there are things we can't do
# at Perl initialization.
sub checkAndStart {

	# Kill the timer, we only want to run once.
	SetTimer(0, \&checkAndStart);

	$os->cleanupTempDirs();

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

		startServer();
	}

	# Now see if the app happens to be up already.
	checkSCActive();

	# Handle the command line --start flag.
	if ($cliStart) {

		my $state = $svcMgr->getServiceState();

		if ($state == SC_STATE_STOPPED) {

			startServer();
		}

		if ($Registry->{SB_USER_REGISTRY_KEY . '/DefaultToWebUI'}) {
			openServer();
		}
		else {
			openControlPanel();
		}
	}
}

sub checkSCActive {
	$svcMgr->checkServiceState();
	
	my $state = $svcMgr->getServiceState();

	if ($state == SC_STATE_RUNNING) {
		SetIcon("SqueezeCenter");
	}
	elsif ($state != SC_STATE_STARTING) {
		SetIcon("SqueezeCenterOff");
	}
}

# see whether SC has downloaded an update version
sub checkForUpdate {
	if ( $svcMgr->getServiceState() != SC_STATE_STARTING && Slim::Utils::Light->checkForUpdate() ) {
		Balloon(string('UPDATE_AVAILABLE'), "Logitech Media Server", "info", 1);
		
		# once the balloon is shown, only poll every hour 
		SetTimer('1:00:00', \&checkForUpdate);
	}
}

sub startServer {
	$svcMgr->start();

	if ($svcMgr->getServiceState() != SC_STATE_STARTING) {

		Balloon(string('STARTING_SQUEEZEBOX_SERVER'), "Logitech Media Server", "", 1);
		SetAnimation(TIMERSECS * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	}
}

# Called from menu when SS is active
sub openServer {

	# Check HTTP first in case the server has changed the HTTP port while running
	my $serverUrl = $svcMgr->checkForHTTP();
	Execute($serverUrl) if $serverUrl;

	$cliStart = $cliInstall = 0;
}

sub openControlPanel {
	Execute($controlPanel);

	$cliStart = $cliInstall = 0;
}

sub showErrorMessage {
	my $message = shift;

	MessageBox($message, "Logitech Media Server", MB_OK | MB_ICONERROR);
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

sub stopServer {
	my $suppressMsg = shift;

	unless (sendCLICommand('stopserver') || $suppressMsg) {

		showErrorMessage(string('STOP_FAILED'));

		return;
	}

	if ($svcMgr->getServiceState() == SC_STATE_RUNNING) {

		Balloon(string('STOPPING_SQUEEZEBOX_SERVER'), "Logitech Media Server", "", 1);

	}
}

sub stopScanner {
	sendCLICommand('abortscan');
}

sub stopComponents {
	my $p = Win32::Process::List->new;

	if ($p->IsError != 1) {

		my %processes = $p->GetProcesses();
		foreach my $pid (%processes) {

			next unless $processes{$pid} =~ /^(?:squeezesvr|squeezeboxcp|scanner|squeezesvc|squeezecenter|squeez~\d).exe$/i;

			my $error;
			Win32::Process::KillProcess($pid, $error);
		}
	}
}

sub updateServerSoftware {
	stopServer(1);
	
	my $logfile  = catdir(scalar($os->dirsFor('log')), 'update.log');
	
	my $installer = Slim::Utils::Light->checkForUpdate();
	
	my $processObj;
	Win32::Process::Create(
		$processObj,
		$installer,
		"\"$installer\" /silent /LOG=\"$logfile\" /TrayIcon",
		0,
		Win32::Process::DETACHED_PROCESS() | Win32::Process::CREATE_NO_WINDOW() | Win32::Process::NORMAL_PRIORITY_CLASS(),
		'.'
	);
	
	Slim::Utils::Light->resetUpdateCheck();
	
	uninstall();
}

sub runWatchDog {
	# cut short if file doesn't exist, don't continue if we can't delete it
	return unless -e $restartFlag && -w _;

	
	my @filestat = stat(_);
	my $age = time() - $filestat[9];

	# check timestamp on file: if it's more than 5 minutes old, don't restart
	if ($age > 300) {
		unlink $restartFlag;
	}

	elsif ($svcMgr->getServiceState() == SC_STATE_STOPPED) {
		unlink $restartFlag;
		startServer();
	}
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

# attempt to stop the server and exit
sub uninstall {
	# Kill the timer, we don't want SC to be restarted
	SetTimer(0);

	# stop the scanner _before_ SC, as it's talking to SC using the CLI
	stopScanner();

	# let's give the scanner a few seconds to be closed before shutting down SC
	sleep 5;

	stopServer(1);

	# stop the control panel and other related processes
	sleep 5;
	stopComponents();
	
	$os->cleanupTempDirs();

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
SetTimer("5:00", \&checkForUpdate);

# Poor man's watchdog: if cache/restart.txt exists, restart SC
SetTimer(":5", \&runWatchDog);

# This is our regular timer which continually checks for existence of
# SS. We could have combined the two timers, but changing the
# frequency of the timer proved problematic.
SetTimer(":" . TIMERSECS);
