use FindBin qw($Bin);

my $cmd = qq("$Bin/squeezecenter.exe");
my @args = ();

# only allow install and remove parameters
if ($ARGV[0] =~ /\binstall\b/i) {
	push @args, '--install';
}
elsif ($ARGV[0] =~ /\bremove\b/i) {
	push @args, '--remove';
}
elsif ($ARGV[0] =~ /\bstart\b/i) {
	$cmd = 'sc';
	push @args, qw(start squeezesvc);
}
else {
	exit;
}

system($cmd, @args);