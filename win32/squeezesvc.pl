use FindBin qw($Bin);
use Win32;

my $cmd = Win32::GetShortPathName( "$Bin/squeezecenter.exe" );

# only allow install and remove parameters
if ($ARGV[0] =~ /\binstall\b/i) {
	$cmd .= ' --install';
}
elsif ($ARGV[0] =~ /\bremove\b/i) {
	$cmd .= ' --remove';
}
elsif ($ARGV[0] =~ /\bstart\b/i) {
	$cmd = 'sc start squeezesvc';
}
else {
	exit;
}

`$cmd $args`;
