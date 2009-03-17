use FindBin qw($Bin);
use Win32;
use Win32::Service;

my $cmd = Win32::GetShortPathName( "$Bin/squeezecenter.exe" );

# only allow install and remove parameters
if ($ARGV[0] =~ /\binstall\b/i) {
	`$cmd --remove`;

	my $args = '';
	foreach (@ARGV) {
		if (/username=(.*)/i) {
			$args .= " --username=$1";
		}
		elsif (/password=(.*)/i) {
			$args .= " --password=$1";
		}
	}

	`$cmd --install $args`;
}
elsif ($ARGV[0] =~ /\bremove\b/i) {
	`$cmd --remove`;
}
elsif ($ARGV[0] =~ /\b(?:re|)start\b/i) {
	Win32::Service::StopService('', 'squeezesvc') if $ARGV[0] =~ /\brestart\b/i;
	
	my %status = ();
	
	my $max = 10;
	
	# wait a few seconds or until squeezesvc has stopped
	Win32::Service::GetStatus('', 'squeezesvc', \%status);

	while ($status{CurrentState} != 0x01 && $max-- > 0) {
		sleep 2;
		Win32::Service::GetStatus('', 'squeezesvc', \%status);
	}
	
	Win32::Service::StartService('', 'squeezesvc');
}
