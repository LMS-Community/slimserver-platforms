package Slim::Utils::MySQLHelper;

# $Id: MySQLHelper.pm 11825 2007-04-25 22:17:42Z adrian $

=head1 NAME

Slim::Utils::MySQLHelper

=head1 SYNOPSIS

Slim::Utils::MySQLHelper->init

=head1 DESCRIPTION

Helper class for launching MySQL, installing the system tables, etc.

=head1 METHODS

=cut

use strict;
use base qw(Class::Data::Inheritable);
use DBI;
use DBI::Const::GetInfoType;
use File::Path;
use File::Slurp;
use File::Spec::Functions qw(:ALL);
use File::Which qw(which);
use Proc::Background;
use Template;

use Slim::Utils::Misc;
use Slim::Utils::OSDetect;
use Slim::Utils::Prefs;
use Slim::Utils::SQLHelper;

{
        my $class = __PACKAGE__;

        for my $accessor (qw(confFile mysqlDir pidFile socketFile needSystemTables processObj)) {

                $class->mk_classdata($accessor);
        }
}

my $OS  = Slim::Utils::OSDetect::OS();

my $serviceName = 'SlimServerMySQL';

=head2 init()

Initializes the entire MySQL subsystem - creates the config file, and starts the server.

=cut

sub init {
	my $class = shift;

	# The DB server might already be up.. if it didn't get shutdown last
	# time. That's ok.
	if (!$class->dbh) {
		$class->startServer;
	}

	return 1;
}

=head2 startServer()

Bring up our private copy of MySQL server.

This is a no-op if you are using a pre-configured copy of MySQL.

=cut

sub startServer {
	my $class   = shift;
	my $service = shift || 0;

	my $isRunning = 0;

	if ($service) {

		my %status = ();

		Win32::Service::GetStatus('', $serviceName, \%status);

		if ($status{'CurrentState'} == 0x04) {

			$isRunning = 1;
		}

	} elsif ($class->pidFile && $class->processObj && $class->processObj->alive) {

		$isRunning = 1;
	}

	if ($isRunning) {

		msg("MySQLHelper: startServer(): MySQL is already running!\n");

		return 0;
	}

	my $mysqld = Slim::Utils::Misc::findbin('mysqld') || do {
		errorMsg("MySQLHelper: startServer() Couldn't find a executable for 'mysqld'! This is a fatal error. Exiting.\n");
		exit;
	};

	my $confFile = $class->confFile;                                                                                                                    
	my $process  = undef;

	# Bug: 3461
	if ($OS eq 'win') {
		$mysqld   = Win32::GetShortPathName($mysqld);
		$confFile = Win32::GetShortPathName($confFile);
	}

	my @commands = ($mysqld,
			'--basedir=/usr',
			'--datadir=/var/lib/mysql',
			'--pid-file=/var/run/mysqld/mysqld.pid',
			'--skip-locking',
			'--socket=/var/run/mysqld/mysqld.sock'
		       );

	$::d_mysql && msgf("MySQLHelper: startServer() About to start MySQL with command: [%s]\n", join(' ', @commands));

	if ($service && $OS eq 'win') {

		my %status = ();

		Win32::Service::GetStatus('', $serviceName, \%status);

		# Attempt to install the service, if it isn't.
		# NB mysqld fails immediately if install is not allowed by user account so don't add this to @commands
		if (scalar keys %status == 0) {

			system( sprintf "%s --install %s %s", $commands[0], $serviceName, $commands[1] );
		}

		Win32::Service::StartService('', $serviceName);

		Win32::Service::GetStatus('', $serviceName, \%status);

		if (scalar keys %status == 0 || ($status{'CurrentState'} != 0x02 && $status{'CurrentState'} != 0x04)) {

			$::d_mysql && msgf("Couldn't run MySQL as a service, will run as a process\n");

			$service = 0;
		}
	}

	# Catch Unix users, and Windows users when we couldn't run as a service.
	if (!$service) {

		$process = Proc::Background->new(@commands);
	}

	my $dbh  = undef;
	my $secs = 30;

	# Give MySQL time to get going..
	for (my $i = 0; $i < $secs; $i++) {

		# If we can connect, the server is up.
		if ($dbh = $class->dbh) {
			$dbh->disconnect;
			last;
		}

		sleep 1;
	}

	if ($@) {
		errorMsg("MySQLHelper: startServer() - server didn't startup in $secs seconds! Fatal! Exiting!\n");
		exit;
	}

	$class->processObj($process);

	return 1;
}

=head2 stopServer()

Bring down our private copy of MySQL server.

This is a no-op if you are using a pre-configured copy of MySQL.

Or are running MySQL as a Windows service.

=cut

sub stopServer {
	my $class = shift;
	my $dbh   = shift || $class->dbh;

	if ($OS eq 'win') {

		my %status = ();
		
		Win32::Service::GetStatus('', $serviceName, \%status);

		if (scalar keys %status != 0 && ($status{'CurrentState'} == 0x02 || $status{'CurrentState'} == 0x04)) {

			$::d_mysql && msg("Running service shutdown.\n");

			if (Win32::Service::StopService('', $serviceName)) {

				return;
			}
			
			errorMsg("Running service shutdown failed!\n");
		}
	}

	# We have a running server & handle. Shut it down internally.
	if ($dbh) {

		$::d_mysql && msg("MySQLHelper: stopServer() Running shutdown.\n");

		$dbh->func('shutdown', 'admin');
		$dbh->disconnect;

		if ($class->_checkForDeadProcess) {
			return;
		}
	}

	# If the shutdown failed, try to find the pid
	my @pids = ();

	if (ref($class->processObj)) {
		push @pids, $class->processObj->pid;
	}

	if (-f $class->pidFile) {
		chomp(my $pid = read_file($class->pidFile));
		push @pids, $pid;
	}

	for my $pid (@pids) {

		next if !$pid || !kill(0, $pid);

		$::d_mysql && msgf("MySQLHelper: stopServer() Killing pid: [%d]\n", $pid);

		kill('TERM', $pid);

		# Wait for the PID file to go away.
		last if $class->_checkForDeadProcess;

		# Try harder.
		kill('KILL', $pid);

		last if $class->_checkForDeadProcess;

		if (kill(0, $pid)) {

			errorMsg("MySQLHelper: stopServer() - server didn't shutdown in 20 seconds!\n");
			exit;
		}
	}

	# The pid file may be left around..
	unlink($class->pidFile);
}

sub _checkForDeadProcess {
	my $class = shift;

	for (my $i = 0; $i < 10; $i++) {

		if (!-r $class->pidFile) {

			$class->processObj(undef);
			return 1;
		}

		sleep 1;
	}

	return 0;
}

=head2 createSystemTables()

Create required MySQL system tables. See the L<MySQL/system.sql> file.

=cut

sub createSystemTables {
	my $class = shift;

	# We need to bring up MySQL to set the initial system tables, then bring it down again.
	$class->startServer;

	my $sqlFile = catdir($class->mysqlDir, 'system.sql');

	# Connect to the database - doesn't matter what user and no database,
	# in order to setup the system tables. 
	#
	# We need to use the mysql_socket on *nix platforms here, as mysql
	# won't bring up the network port until the tables are installed.
	#
	# On Windows, TCP is the default.

	my $dbh = $class->dbh or do {

		errorMsg("MySQLHelper: createSystemTables() Couldn't connect to database: [$DBI::errstr]\n");

		$class->stopServer;

		exit;
	};

	if (Slim::Utils::SQLHelper->executeSQLFile('mysql', $dbh, $sqlFile)) {

		$class->createDatabase($dbh);

		# Bring the server down again.
		$class->stopServer($dbh);

		$dbh->disconnect;

		$class->needSystemTables(0);

	} else {

		errorMsg("MySQLHelper: createSystemTables() - couldn't run executeSQLFile on [$sqlFile]!\n");
		errorMsg("MySQLHelper: createSystemTables() - this is a fatal error. Exiting.\n");
		exit;
	}
}

=head2 dbh()

Returns a L<DBI> database handle, using the dbsource preference setting .

=cut

sub dbh {
	my $class = shift;
	my $dsn   = '';

	if ($OS eq 'win') {

		$dsn = Slim::Utils::Prefs::get('dbsource');
		$dsn =~ s/;database=.+;?//;

	} else {

		$dsn = sprintf('dbi:mysql:mysql_read_default_file=%s', $class->confFile );
	}

	$^W = 0;

	return eval { DBI->connect($dsn, undef, undef, { 'PrintError' => 0, 'RaiseError' => 0 }) };
}

=head2 createDatabase( $dbh )

Creates the initial SlimServer database in MySQL.

'CREATE DATABASE slimserver'

=cut

sub createDatabase {
	my $class  = shift;
	my $dbh    = shift;

	my $source = Slim::Utils::Prefs::get('dbsource');

	# Set a reasonable default. :)
	my $dbname = 'slimserver';

	if ($source =~ /database=(\w+)/) {
		$dbname = $1;
	}

	eval { $dbh->do("CREATE DATABASE $dbname") };

	if ($@) {
		errorMsg("MySQLHelper: createDatabase() - Couldn't create database with name: [$dbname] - [$DBI::errstr]\n");
		errorMsg("MySQLHelper: createDatabase() - this is a fatal error. Exiting.\n");
		exit;
	}
}

=head2 mysqlVersion( $dbh )

Returns the version of MySQL that the $dbh is connected to.

=cut

sub mysqlVersion {
	my $class = shift;
	my $dbh   = shift || return 0;

	my $mysqlVersion = $dbh->get_info($GetInfoType{'SQL_DBMS_VER'}) || 0;

	if ($mysqlVersion && $mysqlVersion =~ /^(\d+\.\d+)/) {

        	return $1;
	}

	return $mysqlVersion || 0;
}

=head2 mysqlVersionLong( $dbh )

Returns the long version string, i.e. 5.0.22-standard

=cut

sub mysqlVersionLong {
	my $class = shift;
	my $dbh   = shift || return 0;

	my ($mysqlVersion) = $dbh->selectrow_array( 'SELECT version()' );

	return $mysqlVersion || 0;
}	

=head2 cleanup()

Shut down MySQL when SlimServer is shut down.

=cut

sub cleanup {
	my $class = shift;

	if ($class->pidFile) {
		$class->stopServer;
	}
}

=head1 SEE ALSO

L<DBI>

L<DBD::mysql>

L<http://www.mysql.com/>

=cut

1;

__END__
