# $Id$
# 
# SqueezeTray.exe controls the starting & stopping of the squeezesvc Windows Service.
#
# If the service is not installed, we'll install it first.
#
# This program relies on Win32::Daemon, which is not part of CPAN.
# http://www.roth.net/perl/Daemon/
#
# The user can choose to run SqueezeCenter as a service, or as an application.
# Running as an application will allow access to mapped network drives.
#
# The checkbox selection will be:
# 'at system start' (service) or 'at login' (app). 
# 
# If the user chooses app - the service will still be installed, but set to
# Manual start.

use strict;
use PerlTray;

use Cwd qw(cwd);
use File::Spec;
use Getopt::Long;
use Socket;
use Encode;

use Win32 qw(GetOSName);
use Win32::Locale;
use Win32::Daemon;
use Win32::Process qw(DETACHED_PROCESS CREATE_NO_WINDOW NORMAL_PRIORITY_CLASS);
use Win32::Process::List;
use Win32::TieRegistry ('Delimiter' => '/');
use Win32::Service;


# Vista only:
#
# When running on Vista SqueezeTray may be run as a normal user or as administrator depending on how it is started
# With the default install it will run as admin the first time when launched from the installer, all subsequent times it will
# run as a normal user.  Vista UAC means that we can only install windows services and start/stop them when running as admin.
# To avoid user confusion we therefore disable all options which are not available when running as a normal user.
#
# prefs and the SqueezeCenter url are stored in a different location on Vista to avoid Vista file virtualisation.

my $vista          = ((Win32::GetOSName())[0] =~ /Vista/);  # running on Vista
my $vistaUser      = $vista && !Win32::IsAdminUser();       # running on Vista as a user (not admin) - reduce menu options

my $timerSecs      = 10;
my $ssActive       = 0;
my $starting       = 0;
my $processObj     = 0;
my $checkHTTP      = 0;
my $lastHTTPPort   = 0;
my $stopMySQL      = 0;

my %strings        = ();

# Passed on the command line by Getopt::Long
my $cliStart       = 0;
my $cliExit        = 0;
my $cliInstall     = 0;
my $cliUninstall   = 0;

my $registryKey    = 'CUser/Software/Logitech/SqueezeCenter';
my $serviceName    = 'squeezesvc';
my $sqlServiceName = 'SqueezeMySQL';

my $atBoot         = $Registry->{"$registryKey/StartAtBoot"};
my $atLogin        = $Registry->{"$registryKey/StartAtLogin"};

my $appExe         = File::Spec->catdir(installDir(), 'server', 'squeezecenter.exe');
my $serverUrl      = File::Spec->catdir($vista ? writableDir() : installDir(), "SqueezeCenter Web Interface.url");
my $prefFile       = File::Spec->catdir(writableDir(), 'prefs', 'server.prefs');
my $language       = getPref('language') || 'EN';


# Dynamically create the popup menu based on SqueezeCenter state
sub PopupMenu {
	my @menu = ();

	my $type = startupType(); # = none, login or auto

	# As a user on Vista we only allow the following as these are all a user can perform:
	# - starting/stopping of the server if type is none, login
	# - toggling of startup type between login and none

	if ($ssActive) {
		push @menu, [sprintf('*%s', string('OPEN_SQUEEZECENTER')), \&openSqueezeCenter];
		push @menu, ["--------"];
		push @menu, [string('STOP_SQUEEZECENTER'), \&stopSqueezeCenterMySQL] if (!$vistaUser || $type =~ /none|login/);
	}
	elsif ($starting) {
		push @menu, [string('STARTING_SQUEEZECENTER'), ""];
	}
	else {
		push @menu, [sprintf('*%s', string('START_SQUEEZECENTER')), \&startSqueezeCenter] if (!$vistaUser || $type =~ /none|login/);
	}

	my $serviceString = string('RUN_AT_BOOT');
	my $appString     = string('RUN_AT_LOGIN');

	# We can't modify the service while it's running
	# So show a grayed out menu.
	my $setNone   = undef;
	my $setAuto   = undef;
	my $setLogin  = undef;

	if (!$ssActive && !$starting) {

		$setNone  = sub { setStartupType('none') };
		$setAuto  = sub { setStartupType('auto') };
		$setLogin = sub { setStartupType('login') };
	}

	if ($type eq 'login') {

		push @menu, ["_ $serviceString", $setAuto, undef] unless $vistaUser;
		push @menu, ["v $appString", $setNone, 1];

	} elsif ($type eq 'auto') {

		push @menu, ["v $serviceString", $setNone, 1] unless $vistaUser;
		push @menu, ["_ $appString", $setLogin, undef]  unless $vistaUser;

	} else {

		push @menu, ["_ $serviceString", $setAuto, undef] unless $vistaUser;
		push @menu, ["_ $appString", $setLogin, undef];
	}

	push @menu, [string('ADDITIONAL_OPTIONS'), \&vistaHelp] if $vistaUser;

	push @menu, ["--------"];
	push @menu, [string('GO_TO_WEBSITE'), "Execute 'http://www.slimdevices.com'"];
	push @menu, [string('EXIT'), "exit"];

	return \@menu;
}

sub vistaHelp {
	MessageBox(string('VISTA_RESTART_AS_ADMIN'), "SqueezeCenter", MB_OK | MB_ICONINFORMATION);
}

# Called when the tray application is invoked again. This can handle
# new startup parameters.
sub Singleton {

	# Had problems using Getopt::Long since @ARGV isn't set.
	# XXX There also seems to be a problem with arguments passed
	# in. $_[0] is not the first parameter, so we use $_[1].
	if (scalar(@_) > 1) {

		if ($_[1] eq '--start') {

			if (!$ssActive && !$starting) {

				startSqueezeCenter();
			}

			if ($ssActive) {

				checkForHTTP();
				Execute($serverUrl);

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

	if ($ssActive) {

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
 
 	elsif ($ssActive) {
		$state = string('SQUEEZECENTER_RUNNING', $lang);
 	}
    
 	else {
		$state = string('SQUEEZECENTER_STOPPED', $lang);
 	}
 
	$state = encode($lang eq 'HE' ? 'cp1255' : 'cp1250', $state);

	return $state;
}

# The regular (heartbeat) timer that checks the state of SqueezeCenter
# and modifies state variables.
sub Timer {

	checkSSActive();

	if ($starting) {

		SetAnimation($timerSecs * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

	} elsif ($ssActive && $checkHTTP && checkForHTTP()) {

		$checkHTTP = 0;

		Execute($serverUrl);
	}

	# Check if user has requested to stop SqueezeCenter And MySQL
	# Only try to stop MySQL service when SqueezeCenter has stopped.
	if (!$ssActive && $stopMySQL) {

		stopMySQLd();

   		$stopMySQL = 0;
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

	# Install the service if it isn't already.
	my %status = ();

	Win32::Service::GetStatus('', $serviceName, \%status);

	if (scalar keys %status == 0) {

		installService();
	}

	if ($cliInstall) {

		my $serviceStart = $Registry->{"LMachine/SYSTEM/CurrentControlSet/Services/$serviceName/Start"};

		my $cKey = $Registry->{'CUser/Software/'};
		my $lKey = $Registry->{'LMachine/Software/'};

		$atBoot  = ($serviceStart && oct($serviceStart) == 2) ? 1 : 0;
		$atLogin = 0;

		$cKey->{'Logitech/'} = {
			'SqueezeCenter/' => {
				'/StartAtBoot'  => $atBoot,
				'/StartAtLogin' => $atLogin,
			},
		};

		$lKey->{'Logitech/'} = { 'SqueezeCenter/' => { '/Path' => installDir() } };

		checkSSActive();

		$checkHTTP = 1; # check server and open browser when it comes up

		return;
	}

	my $startupType = startupType();

	# If we're set to Start at Login, do it, but only if the process isn't
	# already running.
	if (processID() == -1 && $startupType eq 'login') {

		startSqueezeCenter();
	}

	# Now see if the service happens to be up already.
	checkSSActive();

	if ($vistaUser && !$ssActive && !$starting && $startupType eq 'auto') {
		# running as a user on Vista so we can't start a service, fallback to running as an app
		setStartupType('none');
	}

	# Handle the command line --start flag.
	if ($cliStart) {

		if (!$ssActive && !$starting) {

			startSqueezeCenter();
		}

		if ($ssActive) {

			checkForHTTP();
			Execute($serverUrl);

		} else {

			$checkHTTP = 1;
		}

		$cliStart = 0;
	}
}

sub checkSSActive {
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

	if ($state eq 'running') {

		SetIcon("SqueezeCenter");
		$ssActive = 1;
		$starting = 0;

	} else {

		SetIcon("SqueezeCenterOff");
		$ssActive = 0;
	}
}

sub startSqueezeCenter {

	if (startupTypeIsService()) {

		if (!Win32::Service::StartService('', $serviceName)) {

			showErrorMessage(string('START_FAILED'));

			$starting = 0;
			$ssActive = 0;

			return;
		}

	} else {

		runBackground($appExe);
	}

	if (!$ssActive) {

		Balloon(string('STARTING_SQUEEZECENTER'), "SqueezeCenter", "", 1);
		SetAnimation($timerSecs * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

		$starting = 1;
	}
}

sub stopSqueezeCenter {
	my $suppressMsg = shift;

	if (startupTypeIsService()) {

		if (!Win32::Service::StopService('', $serviceName) && !$suppressMsg) {

			showErrorMessage(string('STOP_FAILED'));

			return;
		}

	} else {

		my $pid = processID();

		if ($pid == -1 && !$suppressMsg) {

			showErrorMessage(string('STOP_FAILED'));

			return;
		}

		Win32::Process::KillProcess($pid, 1<<8);
	}

	if ($ssActive) {

		Balloon(string('STOPPING_SQUEEZECENTER'), "SqueezeCenter", "", 1);

		$ssActive = 0;
	}
}

sub stopMySQLd {

	my %status = ();
	Win32::Service::GetStatus('', $sqlServiceName, \%status);

	if (scalar keys %status != 0) {

		if ($status{'CurrentState'} == 1) {

			# Service already stopped

		} elsif (Win32::Service::StopService('', $sqlServiceName)) {

			# Sucessfully stopped service

		} elsif (!$vistaUser) {

			# Service running which we can't stop
			# Display warning, unless running as a user on Vista as we can't stop in this case

			my $t = 'GetStatus Failed';

			Win32::Service::GetStatus('', $sqlServiceName, \%status);

			if (scalar keys %status != 0) {

				$t = "GetStatus CurrentState=$status{'CurrentState'}";
			}

			showErrorMessage(sprintf('%s %s', string('STOP_MYSQL_FAILURE', $t)));
		}
	}

	# if mysqld was run as an app attempt to kill it
	if (my $pid = mysqldID()) {

		Win32::Process::KillProcess($pid, 0);
	}
}

# Called from menu when SS is active
sub openSqueezeCenter {

	# Check HTTP first in case SqueezeCenter has changed the HTTP port while running
	checkForHTTP ();	
	Execute($serverUrl);
}

sub stopSqueezeCenterMySQL {

	stopSqueezeCenter();
	$stopMySQL = 1;
}

sub showErrorMessage {
	my $message = shift;

	MessageBox($message, "SqueezeCenter", MB_OK | MB_ICONERROR);
}

sub startupTypeIsService {

	my $type = startupType();

	# These are the service types.
	if ($type eq 'auto' || $type eq 'manual') {

		return 1;
	}

	return 0;
}

# Determine how the user wants to start SqueezeCenter
sub startupType {

	if ($atLogin) {
		return 'login';
	}

	if ($atBoot) {
		return 'auto';
	}

	return 'none';
}

sub setStartupType {
	my $type = shift;

	if ($type !~ /^(?:login|auto|none)$/) {

		return;
	}

	if ($type eq 'login') {

		$Registry->{"$registryKey/StartAtBoot"}  = $atBoot  = 0;
		$Registry->{"$registryKey/StartAtLogin"} = $atLogin = 1;

		# Force the service to manual start, don't remove it.
		setServiceManual();

	} elsif ($type eq 'none') {

		$Registry->{"$registryKey/StartAtBoot"}  = $atBoot  = 0;
		$Registry->{"$registryKey/StartAtLogin"} = $atLogin = 0;

		setServiceManual();

	} else {

		$Registry->{"$registryKey/StartAtBoot"}  = $atBoot  = 1;
		$Registry->{"$registryKey/StartAtLogin"} = $atLogin = 0;
		
		setServiceAuto();
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
	my $installDir = File::Spec->catdir('C:\Program Files', 'SqueezeCenter');

	# If it's not there, use the current working directory.
	if (!-d $installDir) {

		$installDir = cwd();
	}

	return $installDir;
}

# Return directory for files which SqueezeCenter can save - i.e. location of prefs file
# This is the server dir unless we are running on Vista when it is %ALLUSERSPROFILE%\SqueezeCenter
sub writableDir {

	if ($vista) {
		return File::Spec->catdir($ENV{'ALLUSERSPROFILE'}, 'SqueezeCenter');
	}

	return File::Spec->catdir(installDir(), 'server');
}

# Read pref from the server preference file - lighter weight than loading YAML
sub getPref {
	my $pref = shift;
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

	Win32::Daemon::CreateService({
		'machine'     => '',
		'name'        => $serviceName,
		'display'     => 'SqueezeCenter',
		'description' => "SqueezeCenter Music Server",
		'path'        => $appExe,
		'start_type'  => $type,
	});
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

	my $pid = ($p->GetProcessPid(qr/^squeezecenter\.exe$/))[1];

	return $pid if defined $pid;
	return -1;
}

sub mysqldID {

	my $pidFile  = File::Spec->catdir(writableDir(), 'Cache', 'squeezecenter-mysql.pid');
	my $pid = undef;

	if (-r $pidFile) {

		open PIDFILE, $pidFile;
		$pid = <PIDFILE>;
		close PIDFILE;
		chomp($pid);
	}

	return $pid;
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

# attempt to stop server and mysql and exit
sub uninstall {
	stopSqueezeCenter(1);
	stopMySQLd();

	# wait for service to be fully removed (installer removes before calling us)
	for (my $i = 0; $i < 30 ; ++$i) {

		my %status = ();
		
		Win32::Service::GetStatus('', $serviceName, \%status);

		last if (scalar keys %status == 0);
		
		Sleep(1);
	}

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

	LINE: while (my $line = <DATA>) {

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

			$string = pack "U0C*", unpack "C*", $string;

			$strings{$stringname}->{$language} = $string;
		}
	}
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


__END__
START_FAILED
	DE	SqueezeCenter konnte nicht gestartet werden. Weitere Informationen finden Sie in der Ereignisanzeige und vom Support
	EN	SqueezeCenter would not open. SqueezeCenter may be starting or stopping. Please wait a minute and try again.
	ES	Fallo al iniciar SqueezeCenter. Consulte el Visor de sucesos y póngase en contacto con el servicio de asistencia
	FR	Echec du démarrage du SqueezeCenter. Veuillez consulter le journal des événements et contacter le service d'assistance technique.
	HE	כשל בהפעלת SqueezeCenter. עיין במציג האירועים ופנה למרכז התמיכה.
	IT	Avvio di SqueezeCenter non riuscito. Vedere il visualizzatore eventi e contattare il servizio di assistenza.
	NL	SqueezeCenter kan niet gestart worden. Zie de logboeken en neem contact op met ondersteuning

STOP_FAILED
	DE	SqueezeCenter konnte nicht angehalten werden. Weitere Informationen finden Sie in der Ereignisanzeige und vom Support
	EN	Stopping SqueezeCenter Failed. Please see the Event Viewer & Contact Support
	ES	Fallo al detener SqueezeCenter. Consulte el Visor de sucesos y póngase en contacto con el servicio de asistencia
	FR	Echec de l'arrêt du SqueezeCenter. Veuillez consulter le journal des événements et contacter le service d'assistance technique.
	HE	כשל בעצירת SqueezeCenter. עיין במציג האירועים ופנה למרכז התמיכה.
	IT	Arresto di SqueezeCenter non riuscito. Vedere il visualizzatore eventi e contattare il servizio di assistenza.
	NL	SqueezeCenter kan niet gestopt worden. Zie de logboeken en neem contact op met ondersteuning

RUN_AT_BOOT
	DE	Automatisch bei Systemstart ausführen
	EN	Automatically run at system start
	ES	Ejecutar automáticamente al iniciar el sistema
	FR	Démarrer automatiquement au démarrage du système
	HE	הפעלה אוטומטית עם הפעלת המערכת
	IT	Esegui automaticamente all'avvio del sistema
	NL	Automatisch uitvoeren bij systeemstart

RUN_AT_LOGIN
	DE	Automatisch bei Anmeldung ausführen
	EN	Automatically run at login
	ES	Ejecutar automáticamente al iniciar sesión
	FR	Démarrer automatiquement lors de la connexion
	HE	הפעלה אוטומטית עם הכניסה למערכת
	IT	Esegui automaticamente all'accesso al sistema
	NL	Automatisch uitvoeren bij aanmelden

OPEN_SQUEEZECENTER
	DE	SqueezeCenter öffnen
	EN	Open SqueezeCenter
	ES	Abrir SqueezeCenter
	FR	Ouvrir le SqueezeCenter
	HE	פתח את SqueezeCenter
	IT	Apri SqueezeCenter
	NL	SqueezeCenter openen

START_SQUEEZECENTER
	DE	SqueezeCenter starten
	EN	Start SqueezeCenter
	ES	Iniciar SqueezeCenter
	FR	Démarrer le SqueezeCenter
	HE	הפעל את SqueezeCenter
	IT	Avvia SqueezeCenter
	NL	SqueezeCenter starten

STARTING_SQUEEZECENTER
	DE	SqueezeCenter wird gestartet...
	EN	Starting SqueezeCenter...
	ES	Iniciando SqueezeCenter...
	FR	Démarrage du SqueezeCenter
	HE	מפעיל את SqueezeCenter...
	IT	Avvio di SqueezeCenter in corso...
	NL	SqueezeCenter wordt gestart...

STOPPING_SQUEEZECENTER
	DE	SqueezeCenter wird angehalten...
	EN	Stopping SqueezeCenter...
	ES	Deteniendo SqueezeCenter...
	FR	Arrêt du SqueezeCenter…
	HE	עוצר את SqueezeCenter...
	IT	Arresto di SqueezeCenter in corso...
	NL	SqueezeCenter wordt gestopt...

STOP_SQUEEZECENTER
	DE	SqueezeCenter anhalten
	EN	Stop SqueezeCenter
	ES	Detener SqueezeCenter
	FR	Arrêter le SqueezeCenter
	HE	עצור את SqueezeCenter
	IT	Arresta SqueezeCenter
	NL	SqueezeCenter stoppen

SQUEEZECENTER_STARTING
	DE	SqueezeCenter wird gestartet
	EN	SqueezeCenter Starting
	ES	SqueezeCenter en inicio
	FR	Démarrage du SqueezeCenter
	HE	‏SqueezeCenter מופעל
	IT	Avvio di SqueezeCenter in corso
	NL	SqueezeCenter wordt gestart

SQUEEZECENTER_RUNNING
	DE	SqueezeCenter wird ausgeführt
	EN	SqueezeCenter Running
	ES	SqueezeCenter en ejecución
	FR	SqueezeCenter en cours d'exécution
	HE	‏SqueezeCenter פועל
	IT	SqueezeCenter è in esecuzione
	NL	SqueezeCenter is actief

SQUEEZECENTER_STOPPED
	DE	SqueezeCenter angehalten
	EN	SqueezeCenter Stopped
	ES	SqueezeCenter detenido
	FR	SqueezeCenter arrêté
	HE	‏SqueezeCenter נעצר
	IT	SqueezeCenter è stato arrestato
	NL	SqueezeCenter is gestopt

GO_TO_WEBSITE
	DE	Logitech Website öffnen
	EN	Go to Logitech Web Site
	ES	Ir al sitio Web de Logitech
	FR	Accéder au site Web de Logitech
	HE	עבור אל אתר האינטרנט של Logitech
	IT	Vai al sito Web Logitech
	NL	Naar de Logitech-website

EXIT
	DE	B&eenden
	EN	E&xit
	ES	&Salir
	FR	&Quitter
	HE	י&ציאה
	IT	E&sci
	NL	Af&sluiten

STOP_MYSQL_FAILURE
	DE	Fehler beim Ausführen von StopService in MySQL!
	EN	Running StopService on MySQL failed!
	ES	Error de ejecución de StopService en MySQL.
	HE	כשל בהפעלת StopService ב-MySQL!
	IT	Esecuzione di StopService in MySQL non riuscita.
	NL	Kan StopService niet op MySQL uitvoeren!

WRITE_FAILED
	DE	Speichern nicht möglich in:
	EN	Unable to write to
	ES	Imposible escribir en
	HE	אין אפשרות לכתוב אל
	IT	Impossibile scrivere in
	NL	Kan niet wegschrijven naar

ADDITIONAL_OPTIONS
	DE	Weitere Optionen
	EN	Additional Options
	ES	Opciones adicionales
	HE	אפשרויות נוספות
	IT	Opzioni aggiuntive
	NL	Extra opties

VISTA_RESTART_AS_ADMIN
	DE	Wenn Sie SqueezeCenter unter Windows Vista als Administrator ausführen, stehen Ihnen weitere Startoptionen zur Verfügung. Schließen Sie dazu die Anwendung, wählen Sie im Startmenü 'Alle Programme' und 'SqueezeCenter', klicken Sie mit der rechten Maustaste auf 'SqueezeCenter' und wählen Sie 'Als Administrator ausführen'.
	EN	On Windows Vista, running SqueezeCenter as an administrator gives access to additional startup options. To run as an administrator, close this program, navigate to 'All Programs', 'SqueezeCenter', 'SqueezeCenter' from the start menu, right click and select 'Run as administrator'.
	ES	En Windows Vista, ejecutar SqueezeCenter como administrador da acceso a opciones de inicio adicionales. Para ejecutar como administrador, cierre este programa, vaya al menú inicio, 'Todos los programas', 'SqueezeCenter'. Haga clic con el botón derecho del ratón en 'SqueezeCenter' y seleccione 'Ejecutar como administrador'.
	HE	ב-Windows Vista, הפעלת SqueezeCenter כמנהל מערכת מאפשרת גישה לאפשרויות הפעלה נוספות. להפעלה כמנהל מערכת, סגור את התוכנית, נווט אל All Programs (כל התוכניות), SqueezeCenter‏, SqueezeCenter מתפריט Start (התחל), לחץ לחיצה ימנית ובחר את האפשרות Run as administrator (הפעל כמנהל).
	IT	In Windows Vista, se si esegue SqueezeCenter con privilegi di amministratore è possibile accedere a opzioni di avvio aggiuntive. Per eseguirlo con privilegi di amministratore, chiudere questo programma, selezionare Tutti i programmi, SqueezeCenter, SqueezeCenter dal menu Start, fare clic col pulsante destro del mouse e selezionare Esegui come amministratore.
	NL	Wanneer je SqueezeCenter op Windows Vista met beheerdersrechten uitvoert, heb je toegang tot extra opstartopties. Sluit hiervoor dit programma en ga via het Start-menu naar 'Alle programma's', 'SqueezeCenter', 'SqueezeCenter'. Rechtsklik vervolgens op 'Als beheerder uitvoeren'.

