package Plugins::M6Encore::Plugin;

use strict;
use File::Spec::Functions qw(catdir);

use base qw(Slim::Plugin::Base);

use constant SKIN_NAME => 'Encore';

# we're going to override the stock DigitalInput plugin with our own version
sub postinitPlugin {
	my $class = shift;

	$class->initIconProxy();
	
	require Plugins::M6Encore::DigitalInput;
	Slim::Plugin::DigitalInput::Plugin->initPlugin();
	
	Slim::Networking::Slimproto->addPlayerClass(13, 'm6encore', {
		client => 'Plugins::M6Encore::Player',
		display => 'Slim::Display::NoDisplay'
	});
}


=pod
	We always want to have our own, custom skins for the player UI.
	
	Check what image files we have and re-direct access to them via
	a helper method. In case the request comes from an Encore player
	we go to send the custom file. Otherwise the default behaviour.
	
	All this does is add the skinOverride to the params hash to tell
	the graphics handler to pick up image files from a different folder.
=cut

sub initIconProxy {
	# find all images in our custom skin folder
	my $skinMgr = Slim::Web::HTTP::getSkinManager();
	my ($tplDir) = grep /M6Encore/, @{$skinMgr->{templateDirs}};
	$tplDir = catdir($tplDir, SKIN_NAME);
	
	my @images;
	
	my $files = File::Next::files( { file_filter => sub { /png$/ } }, $tplDir );

	while ( my ($dir, $file, $fullpath) = $files->() ) {
		if ( my ($image) = $fullpath =~ /$tplDir\/(.*)\.png/ ) {
			push @images, $image;
		}
	}
	
	Slim::Web::Pages->addPageFunction(
		join('|', map { "\Q$_\E" } @images),
		sub {
			my ($client, $params, $callback, $httpClient, $response) = @_;

			# XXX - the user agent string could require some tweaking. It should be set to something unique in the custom jive build
			if ( $params->{userAgent} && $params->{userAgent} =~ /squeezeplay.*\QUnversioned-directory (x86_64)\E/i ) {
				$params->{skinOverride} = SKIN_NAME;
			}

			# the following code is stolen from Slim::Web::HTTP::generateHTTPResponse

			# We need to track if we have an async artwork request so 
			# we don't return data out of order
			my $async = 0;
			my $sentResponse = 0;

			my ($body, $mtime, $inode, $size, $contentType) = Slim::Web::Graphics::artworkRequest(
				$client, 
				$params->{path},
				$params,
				sub {
					$sentResponse = 1;
					$callback->(@_);
					
					if ( $async ) {
						Slim::Networking::Select::addRead($httpClient, \&Slim::Web::HTTP::processHTTP);
					}
				},
				$httpClient,
				$response,
			);
			
			# If artworkRequest did not directly call the callback, we are in an async request
			if ( !$sentResponse ) {
				Slim::Networking::Select::removeRead($httpClient);
				$async = 1;
			}
		}
	);
}

1;