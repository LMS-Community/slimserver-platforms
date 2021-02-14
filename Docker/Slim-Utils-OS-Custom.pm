package Slim::Utils::OS::Custom;

use strict;
use File::Spec::Functions qw(catdir);

use base qw(Slim::Utils::OS::Linux);

use constant MUSIC_DIR => '/music';

sub initDetails {
	my $class = shift;

	$class->{osDetails} = $class->SUPER::initDetails();
	$class->{osDetails}->{osName} .= " (Docker)";

	return $class->{osDetails};
}

sub initPrefs {
	my ($class, $prefs) = @_;

	$prefs->{wizardDone} = 1;
	$prefs->{libraryname} = Slim::Utils::Strings::string('SQUEEZEBOX_SERVER');

	if (-d MUSIC_DIR) {
		$prefs->{mediadirs} = $prefs->{ignoreInImageScan} = $prefs->{ignoreInVideoScan} = [ MUSIC_DIR ];
	}
}

sub dirsFor {
	my ($class, $dir) = @_;

	my @dirs = $class->SUPER::dirsFor($dir);

	if ($dir eq 'music' && -d MUSIC_DIR) {
		push @dirs, MUSIC_DIR;
	}
	elsif ($dir eq 'Plugins') {
		push @dirs, catdir($::cachedir, 'Plugins');
		push @INC, $::cachedir;
	}

	return wantarray() ? @dirs : $dirs[0];
}

sub ignoredItems {
	return (
		# system paths in the fs root which will not contain any music
		'bin'          => '/',
		'boot'         => '/',
		'config'       => '/',
		'dev'          => '/',
		'etc'          => '/',
		'lib'          => '/',
		'lib64'        => '/',
		'opt'          => '/',
		'proc'         => '/',
		'run'          => '/',
		'sbin'         => '/',
		'srv'          => '/',
		'sys'          => '/',
		'tmp'          => '/',
		'usr'          => '/',
		'var'          => '/',
		# Docker has become popular on Synology... add some of the Synology specific exceptions:
		'@AntiVirus'   => 1,
		'@appstore'    => 1,   # Synology package manager
		'@autoupdate'  => 1,
		'@clamav'      => 1,
		'@cloudsync'   => 1,
		'@database'    => 1,   # databases store
		'@download'    => 1,
		'@eaDir'       => 1,   # media indexer meta data
		'@img_bkp_cache' => 1,
		'@maillog'     => 1,
		'@MailScanner' => 1,
		'@optware'     => 1,   # NSLU2-Linux Optware system
		'@postfix'     => 1,
		'@quarantine'  => 1,
		'@S2S'         => 1,
		'@sharesnap'   => 1,
		'@spool'       => 1,   # mail/print/.. spool
		'@SynoFinder-log'             => 1,
		'@synodlvolumeche.core'       => 1,
		'@SynologyApplicationService' => 1,
		'@synologydrive'              => 1,
		'@SynologyDriveShareSync'     => 1,
		'@synopkg'     => 1,
		'@synovideostation'           => 1,
		'@tmp'         => 1,   # system temporary files
		'upd@te'       => 1,   # firmware update temporary directory
		'#recycle'     => 1,
		'#snapshot'    => 1,
	);
}

sub aclFiletest {
	return sub {
		my $path = shift || return;

		{
			use filetest 'access';
			return (! -r $path) ? 0 : 1;
		}
	};
}

sub installerOS { 'src' };

# we don't really support auto-update, but we need to make the update checker believe so, or it wouldn't check for us
sub canAutoUpdate {
	# make sure auto download is always enabled - we don't rally auto-update, but this way we're called when we have update info
	Slim::Utils::Prefs::preferences('server')->set('autoDownloadUpdate', 1);

	# dirty hack to only return true when called from the update checker...
	my ($subr) = (caller(1))[3];
	return $subr eq 'Slim::Utils::Update::checkVersion' ? 1 : 0;
}

sub runningFromSource {
	# dirty hack to only return true when called from the settings handler...
	my ($subr) = (caller(1))[3];
	return $subr eq 'Slim::Web::Settings::Server::Software::handler' ? 1 : 0;
}

# set global variable to be shown in the web UI, but don't return anything to not trigger any download
sub getUpdateParams {
	$::newVersion = Slim::Utils::Strings::string('SERVER_UPDATE_AVAILABLE_SHORT');
	return;
}


1;