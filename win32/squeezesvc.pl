use FindBin qw($Bin);
use File::Which;
use Getopt::Long;
use Win32;
use Win32::Service;

my $SVC = 'squeezesvc';

my $cmd = Win32::GetShortPathName( "$Bin/SqueezeSvr.exe" );
my $sc  = which('sc.exe');

my ($username, $password, $install, $start, $restart, $remove);

GetOptions(
	'remove'     => \$remove,
	'install'    => \$install,
	'start'      => \$start,
	'restart'    => \$restart,
	'username=s' => \$username,
	'password=s' => \$password,
);

# only allow install and remove parameters
if ($install) {

	# we must define the hostname - use localhost (.) if none is defined
	$username = ".\\$username" if $username && $username !~ /\\/;
	
	# try to use Windows' SC tool first - much faster than using the server binary
	if ($sc) {
	
		# configure user to run the server - he needs the right to logon as a service
		if ($username) {
			my $user = $username;
			$user =~ s/^.*\\//;
			
			my $grant = PerlApp::extract_bound_file('grant.exe');
			`$grant add SeServiceLogonRight $user` if $username && $grant;
		}

		my $args = '';
		
		$args .= " obj= $username" if $username;
		$args .= " password= $password" if $password;

		`$sc delete $SVC`;
		`$sc create $SVC binPath= "$Bin/SqueezeSvr.exe" start= auto DisplayName= "Logitech Media Server" $args`;
		`$sc description $SVC "Logitech Media Server - streaming music server"`;
	}

	my %status = ();
	Win32::Service::GetStatus('', $SVC, \%status);
	
	if (!$sc || !scalar(keys %status)) {
		my $args = '';
		$args .= " --username=$username" if $username;
		$args .= " --password=$password" if $password;

		`$cmd --remove`;
		`$cmd --install auto $args`;
	}
}

elsif ($remove && $sc) {
	`$sc delete $SVC`;
}
elsif ($remove) {
	`$cmd --remove`;
}

elsif ($restart || $start) {
	Win32::Service::StopService('', $SVC) if $restart;
	
	my %status = ();
	
	my $max = 10;
	
	# wait a few seconds or until squeezesvc has stopped
	Win32::Service::GetStatus('', $SVC, \%status);

	while ($status{CurrentState} != 0x01 && $max-- > 0) {
		sleep 2;
		Win32::Service::GetStatus('', $SVC, \%status);
	}
	
	Win32::Service::StartService('', $SVC);
}
