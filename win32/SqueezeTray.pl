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
my $prefFile       = File::Spec->catdir(writableDir(), 'prefs', 'server.prefs');
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

			if (!$scActive && !$starting) {

				startSqueezeCenter();
			}

			if ($scActive) {

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
 
	$state = encode($lang eq 'HE' ? 'cp1255' : 'cp1250', $state);

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

		Execute($serverUrl);
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

		$Registry->{'CUser/Software/'}->{'Logitech/'} = {
			'SqueezeCenter/' => {
				'/StartAtLogin' => defined $atLogin ? $atLogin : 1
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

			checkForHTTP();
			Execute($serverUrl);

		} else {

			$checkHTTP = 1;
		}

		$cliStart = 0;
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
	if ($state eq 'running') {

		SetIcon("SqueezeCenter");
		$scActive = 1;
		$starting = 0;

	} else {

		SetIcon("SqueezeCenterOff");
		$scActive = 0;
	}
}

sub startSqueezeCenter {

	runBackground($appExe);

	if (!$scActive) {

		Balloon(string('STARTING_SQUEEZECENTER'), "SqueezeCenter", "", 1);
		SetAnimation($timerSecs * 1000, 1000, "SqueezeCenter", "SqueezeCenterOff");

		$starting = 1;
	}
}

# Called from menu when SS is active
sub openSqueezeCenter {

	# Check HTTP first in case SqueezeCenter has changed the HTTP port while running
	checkForHTTP ();	
	Execute($serverUrl);
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

	if (grep /$serviceName/, map {$services{$_}} keys %services) {
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
	my $pid = ($p->GetProcessPid(qr/^squeez(ecenter|~\d).exe$/))[1];

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

	my $pid = processID();

	if ($pid == -1 && !$suppressMsg) {

		showErrorMessage(string('STOP_FAILED'));

		return;
	}

	Win32::Process::KillProcess($pid, 1<<8);

	if ($scActive) {

		Balloon(string('STOPPING_SQUEEZECENTER'), "SqueezeCenter", "", 1);

		$scActive = 0;
	}
}


# attempt to stop SqueezeCenter and exit
sub uninstall {
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

	LINE: foreach my $line (split('\n', strings())) {

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


sub strings {
	return q/
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
/;
}