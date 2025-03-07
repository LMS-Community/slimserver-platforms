#!/usr/bin/perl -w

use strict;
use warnings;

## Load in certain modules for things we're going to do later...
use Cwd;
use File::Basename;
use File::Copy;
use File::Path;
use File::Spec::Functions qw(:ALL);
use Getopt::Long;
use POSIX qw(strftime);

use constant DESTDIR_NOT_REQUIRED => '[not required]';

## Here we set some basic settings.. most of these dont need to change very often.
my $squeezeCenterStartupScript = "server/slimserver.pl";
my $sourceDirsToExclude = ".vscode .vstags .secrets .gitignore .editorconfig .svn .git .github t tests slimp3 squeezebox /softsqueeze tools ext/source ext-all-debug.js build Firmware/*.bin NYTProf Plugins/*";
my $revisionTextFile = "server/revision.txt";
my $revision;
my $myVersion = "1.1.0";
my $defaultDestName = "lyrionmusicserver";
my $defaultReleaseType = "nightly";

## Windows Specific Stuff
my $windowsPerlDir = "C:\\perl";
my $windowsPerlPath = "$windowsPerlDir\\bin\\perl.exe";

## Directories to exclude when building certain packages...
my $dirsToExcludeForLinuxTarball = "i386-freebsd-64int MSWin32-x86-multi-thread MSWin32-x64-multi-thread darwin darwin-x86_64 PreventStandby i86pc-solaris-thread-multi-64int powerpc-linux sparc-linux";
my $dirsToExcludeForLinuxPackage = "$dirsToExcludeForLinuxTarball 5.10 5.12 5.14 5.16 5.18";
my $dirsToExcludeForFreeBSDTarball = "MSWin32-x86-multi-thread MSWin32-x64-multi-thread PreventStandby i386-linux x86_64-linux i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux arm-linux armhf-linux powerpc-linux aarch64-linux icudt46b.dat";
my $dirsToExcludeForARMTarball = "MSWin32-x86-multi-thread MSWin32-x64-multi-thread PreventStandby i386-linux x86_64-linux i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux i386-freebsd-64int powerpc-linux icudt46b.dat icudt58b.dat";
my $dirsToExcludeForPPCTarball = "MSWin32-x86-multi-thread MSWin32-x64-multi-thread PreventStandby i386-linux x86_64-linux i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux arm-linux armhf-linux i386-freebsd-64int aarch64-linux icudt46l.dat icudt58l.dat";
my $dirsToExcludeForARMDeb = "$dirsToExcludeForARMTarball 5.10 5.12 5.14 5.16 5.18";
my $dirsToExcludeForx86_64Deb = "5.10 5.12 5.14 5.16 5.18 MSWin32-x86-multi-thread MSWin32-x64-multi-thread PreventStandby i386-linux i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux arm-linux armhf-linux i386-freebsd-64int powerpc-linux aarch64-linux icudt46b.dat icudt58b.dat";
my $dirsToExcludeFori386Deb = "5.10 5.12 5.14 5.16 5.18 MSWin32-x86-multi-thread MSWin32-x64-multi-thread PreventStandby x86_64-linux i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux arm-linux armhf-linux i386-freebsd-64int powerpc-linux aarch64-linux icudt46b.dat icudt58b.dat";
my $dirsToExcludeForLinuxNoCpanTarball = "i386-freebsd-64int MSWin32-x86-multi-thread MSWin32-x64-multi-thread i86pc-solaris-thread-multi-64int darwin darwin-x86_64 i386-linux sparc-linux x86_64-linux arm-linux armhf-linux powerpc-linux aarch64-linux /arch/ PreventStandby";
my $dirsToExcludeForLinuxNoCpanLightTarball = $dirsToExcludeForLinuxNoCpanTarball . " /Bin/ /HTML/! /Firmware/ /MySQL/ Graphics/CODE2000* Plugin/DateTime DigitalInput iTunes LineIn LineOut MusicMagic RSSNews Rescan SavePlaylist SlimTris Snow Plugin/TT/ Visualizer xPL";
my $dirsToIncludeForLinuxNoCpanLightTarball = "EN.*html/images CPAN/HTML";
my $dirsToExcludeForMacOS = "5.10 5.12 5.14 5.16 5.20 5.22 5.24 5.26 5.28 5.30 5.32 5.36 5.38 5.40 i386-freebsd-64int i386-linux x86_64-linux x86_64-linux-gnu-thread-multi MSWin32 i86pc-solaris-thread-multi-64int arm-linux armhf-linux powerpc-linux sparc-linux aarch64-linux";
my $dirsToExcludeForWin64 = "5.10 5.12 5.14 5.16 5.18 5.20 5.22 5.24 5.26 5.28 5.30 5.34 5.36 5.38 5.40 i386-freebsd-64int i386-linux x86_64-linux x86_64-linux-gnu-thread-multi i86pc-solaris-thread-multi-64int darwin darwin-x86_64 sparc-linux arm-linux armhf-linux powerpc-linux aarch64-linux OS/Debian.pm OS/Linux.pm OS/Unix.pm OS/OSX.pm OS/RedHat.pm OS/Suse.pm OS/SlimService.pm OS/Synology.pm OS/SqueezeOS.pm icudt46b.dat icudt46l.dat icudt58b.dat icudt58l.dat";

# for Docker we provide x86_64 and armhf for Perl 5.36 only
my $dirsToExcludeForDocker = "$dirsToExcludeForLinuxPackage 5.20 5.22 5.24 5.26 5.28 5.30 5.32 5.34 5.38 5.40 i386-linux i86pc-solaris-thread-multi-64int sparc-linux powerpc-linux icudt46b.dat icudt58b.dat";

# Musical Fidelity comes with Perl 5.22
my $dirsToExcludeForEncore = "$dirsToExcludeForLinuxPackage 5.20 5.24 5.26 5.28 5.30 5.32 5.34 5.36 5.38 5.40 i386-linux arm-linux armhf-linux aarch64-linux i86pc-solaris-thread-multi-64int sparc-linux powerpc-linux icudt46l.dat icudt46b.dat";

## Initialize some variables we'll use later
my ($build, $destName, $destDir, $buildDir, $sourceDir, $version, $noCPAN, $fakeRoot, $light, $freebsd, $arm, $encore, $ppc, $x86_64, $i386, $releaseType, $release, $tag);


##############################################################################################
## Begin the main run of the build... based on input from the user, and dynamically	    ##
## picked up content like the version #, we'll build only the appropriate files requested   ##
##############################################################################################
sub main {
	## Find out if the user gave us any data.. if not, post the help and quit
	checkCommandOptions();

	## Get our version #, based on data supplied by user
	$version = getVersion();

	## Right before we start actually building stuff, print out our config options...
	printOptions();

	## Set up the directories we need to do to our build
	setupDirectories();

	## Set the build tree up now... we do this for every distribution we build.
	setupBuildTree();

	## Ok, begin the IF statement... what are we building?
	doCommandOptions();
}

##############################################################################################
## Walk through the options passed in by the user, and see if they make sense. If they      ##
## don't, we'll exit here and show them the usage guidelines.				    ##
##############################################################################################
sub checkCommandOptions {
	## First, lets make sure they sent the most basic option we need, a build target...
	GetOptions(
			'build=s'       => \$build,
			'buildDir=s'    => \$buildDir,
			'sourceDir=s'   => \$sourceDir,
			'destName=s'    => \$destName,
			'destDir=s'     => \$destDir,
			'noCPAN'        => \$noCPAN,
			'freebsd'       => \$freebsd,
			'x86_64'        => \$x86_64,
			'i386'          => \$i386,
			'arm'           => \$arm,
			'ppc'           => \$ppc,
			'encore'        => \$encore,
			'light'         => \$light,
			'releaseType=s' => \$releaseType,
			'tag=s'         => \$tag,
			'fakeRoot'      => \$fakeRoot);

	if ( !$build ) {
		showUsage();

		exit(1);
	};

	if ($build =~ /^readynasv2$/) {
		print "Bye, bye ReadyNAS. We're no longer going to build for you. It's time to move on.\n";
		exit(0);
	}

	if ($build =~ /^tarball|docker|debian|rpm|macos|win64$/) {
		## releaseType is an option, but if its not there, we need
		## to default it to 'nightly'
		if (!$releaseType) {
			$releaseType = "$defaultReleaseType";
		} elsif ( $releaseType ne "nightly" && $releaseType ne "release" ) {
			print "INFO: \$releaseType passed in is incorrect. Please use either \'nightly\' or \'release\'.\n";
		}

		if ($build eq 'docker') {
			$destDir = DESTDIR_NOT_REQUIRED;
		}

		## If they passed in all the options, lets go forward...
		if ($buildDir && $sourceDir && $destDir && ($tag || $build ne 'docker')) {
			print "INFO: Required variables passed in. Moving forward.\n";
			return $build;

		## otherwise, fail and give them the usage guidelines again
		} else {
			print "INFO: Required data missing.\n";
			showUsage();
			exit 1;
		}

	## Now, if they gave us a Build option, but it doesnt make sense... fail
	} else {
		print "INFO: Invalid 'build' option passed in... \n";
		showUsage();
		exit 1;
	}
	return $build;
}

##############################################################################################
## Here we search through the Lyrion Music Server startup script to dynamically grab the version  ##
## number for the rest of our script.							    ##
##############################################################################################

sub getVersion {
	## We check the startup script for the version # info on this build. For now, we'll call this
	## the source of truth for the version information.
	my @temparray;
	open(SLIMSERVERPL, "$sourceDir/$squeezeCenterStartupScript") or die "Couldn't open $sourceDir/$squeezeCenterStartupScript to get the version # of this release: $!\n";
	while (<SLIMSERVERPL>) {
		if (/our \$VERSION/) {
			my @temparray = split(/\'/, $_);
			$version = "$temparray[1]";
		}
	}
	close(SLIMSERVERPL);

	if (!$version) {
		die "Couldn't find the version # in $sourceDir/$squeezeCenterStartupScript... aborting built.\n";
	}

	return $version;
}

##############################################################################################
## Begin the main run of the build... based on input from the user, and dynamically	    ##
## picked up content like the version #, we'll build only the appropriate files requested   ##
##############################################################################################
sub printOptions {
	print "INFO: \$buildDir 	-> $buildDir\n";
	print "INFO: \$destDir		-> $destDir\n";
	print "INFO: \$sourceDir	-> $sourceDir\n";
	print "INFO: \$version		-> $version\n";
	print "INFO: \$squeezeCenterStartupScript	-> $sourceDir/$squeezeCenterStartupScript\n";
	print "INFO: \$releaseType	-> $releaseType\n";
}

##############################################################################################
## We need to set up the directories for the build... 					    ##
## 											    ##
##############################################################################################
sub setupDirectories {
	## First, check if the buildDir exists... we need a clean directory to build our code.
	if (-d $buildDir) {
		print "INFO: Source Directory ($buildDir) already existed, erasing it so we can start clean...\n";
		rmtree($buildDir);
	}

	## Now, create a new build directory
	mkpath($buildDir) or die "Problem: couldn't make $buildDir!\n";
	print "INFO: Build Directory ($buildDir) was created...\n";

	## Finally, create the destination directory, if it doesnt exist. We don't care if
	## it exists already, because someone might want to put this into a more generic
	## directory that has other files in it.
	if ($destDir eq DESTDIR_NOT_REQUIRED) {
		print "INFO: Dest Directory is not required, not creating...\n";
	}
	elsif (!-d $destDir) {
		mkpath($destDir) or die "Problem: couldn't make $destDir!\n";
		print "INFO: Dest Directory ($destDir) was created...\n";
	} else {
		print "INFO: Dest Directory ($destDir) already existed, not creating...\n";
	}
}


##############################################################################################
## No matter what we are building, we're going to move it away from the Git source directory##
## and move it into a building directory. 						    ##
##############################################################################################
sub setupBuildTree {
	# Create a copy of the Git source directory without additional
	# directories or .git turd files for the build.

	## Set up directories to exclude when we start the build...
	my @sourceExcludeArray = split(/ /, $sourceDirsToExclude);
	my $sourceExclude = join(' --exclude ', @sourceExcludeArray);

	## If this is created, we need to begin it with '--exclude'... but if it doesnt, do not set it..
	if ($sourceExclude) {
		$sourceExclude = "--exclude $sourceExclude";
	}

	print "INFO: Making copy of server source ($sourceDir -> $buildDir)\n";

	## Exclude the .git directory, and anything else we configured in the beginning of the script.
	print("rsync -a --quiet $sourceExclude $sourceDir/server $sourceDir/platforms $buildDir\n");
	system("rsync -a --quiet $sourceExclude $sourceDir/server $sourceDir/platforms $buildDir");

	## Verify that things went OK during the transfer...
	if (!-d "$buildDir/server") {
		die "Problem: export of server files failed - $buildDir/server directory!";
	}

	## Force some permissions, just in case they weren't already set
	chmod 0755, "$buildDir/$squeezeCenterStartupScript";
	chmod 0755, "$buildDir/server/scanner.pl";
	chmod 0755, "$buildDir/server/gdresized.pl";

	# Write out the revision number
	if ($revision = getRevisionForRepo()) {
		my $date = `date`;

		print "INFO: Last Revision number is: $revision\n";

		open(REV, ">$buildDir/$revisionTextFile") or die "Problem: Couldn't write out $buildDir/$revisionTextFile : $!\n";
		print REV "$revision\n$date";
		close(REV);
	}
}

##############################################################################################
## Assuming everythings worked so far, we'll actually start building the packages. 	    ##
##############################################################################################
sub doCommandOptions {
	## Check if there's a destName passed in
	## $destName is used for Tarballs, Windows and Mac OSX packages. Linux packages
	## have their own naming schemas.

	if (!$destName) {
		$destName = "$defaultDestName-$version-$revision";
	}

	## If we're building a tarball, do the tarball only...
	if ($build eq "tarball") {

		if ( $releaseType && $releaseType eq "release" ) {
			$destName =~ s/-$revision//;
		}

		## If we're building without CPAN libraries, make sure thats in the filename...
		if ($noCPAN && $light) {
			## Use the NO CPAN Light variables
			buildTarball($dirsToExcludeForLinuxNoCpanLightTarball, "$destDir/$destName-noCPAN-light", $dirsToIncludeForLinuxNoCpanLightTarball);
		} elsif ($noCPAN) {
			## Use the NO CPAN variables
			buildTarball($dirsToExcludeForLinuxNoCpanTarball, "$destDir/$destName-noCPAN");
		} elsif ($freebsd) {
			## Don't include Linux binaries
			buildTarball($dirsToExcludeForFreeBSDTarball, "$destDir/$destName-FreeBSD");
		} elsif ($arm) {
			buildTarball($dirsToExcludeForARMTarball, "$destDir/$destName-arm-linux");
		} elsif ($ppc) {
			buildTarball($dirsToExcludeForPPCTarball, "$destDir/$destName-powerpc-linux");
		} elsif ($encore) {
			system("mkdir -p \"$buildDir/server/Plugins\"; rm -rf \"$buildDir/server/Plugins/*\"");
			system("cp -R \"$buildDir/platforms/MusicalFidelity/M6Encore\" \"$buildDir/server/Plugins/\" ");
			copy("$buildDir/platforms/MusicalFidelity/Custom.pm", "$buildDir/server/Slim/Utils/OS");
			move("$buildDir/server/CPAN/arch/5.22/x86_64-linux-thread-multi", "$buildDir/server/CPAN/arch/5.22/x86_64-linux");
			buildTarball($dirsToExcludeForEncore, "$destDir/$destName-MusicalFidelity", "Plugins/M6Encore");
		} else {
			## Use the CPAN variables
			buildTarball($dirsToExcludeForLinuxTarball, "$destDir/$destName");
		}

	} elsif ($build eq "docker") {
		buildDockerImage();

	} elsif ($build eq "debian") {
		## Build a Debian Package
		buildDebian();

	} elsif ($build eq "rpm") {
		## Run the RPM
		buildRPM();

	} elsif ($build eq "macos") {
		## Build the Mac OSX menu bar item
		$destName =~ s/$defaultDestName/LyrionMusicServer/;

		if ( $releaseType && $releaseType eq "release" ) {
			$destName =~ s/-$revision//;
		}

		buildMacOS("$destName");

	} elsif ($build eq "win64") {
		## Build the Windows 64bit Installer
		$destName =~ s/$defaultDestName/LyrionMusicServer/;
		# buildZIPArchive($dirsToExcludeForWin64, "$destDir/$destName-win64");
		buildWin64("$destName-win64");

	}
}

##############################################################################################
## We need to know the revision # of the code, so that we can put it into the source tree   ##
##############################################################################################
sub getRevisionForRepo {
	my $_getRevision = sub {
		my $repo = shift;

		my $rev;
		if (-d "$sourceDir/$repo/.git") {
			$rev = `git --git-dir=$sourceDir/$repo/.git log -n 1 --pretty=format:%ct`;
			$rev =~ s/\s*$//s;
		}

		return $rev;
	};

	my $revision;
	my $serverRevision = $_getRevision->('server');
	my $platformsRevision = $_getRevision->('platforms') if $serverRevision;

	if ($serverRevision && $platformsRevision) {
		$revision = $serverRevision > $platformsRevision ? $serverRevision : $platformsRevision;
	} else {
		$revision = 'UNKNOWN';
	}

	return $revision;
}

##############################################################################################
## display the help
##############################################################################################
sub showUsage {
	print "buildme.pl - version ($myVersion) - Help \n";
	print "-------------------------------------------\n";
	print "This script can build all of our versions \n";
	print "of Lyrion Music Server... but only one at a time.\n";
	print "Each distribution has its own options, \n";
	print "listed below... don't try to mix them up! :)\n";
	print "\n";
	print "Parameters for all builds:\n";
	print "    --buildDir <dir>             - The directory to do temporary work in\n";
	print "    --sourceDir <dir>            - The location of the source code repository\n";
	print "                                   that you've checked out from Git\n";
	print "    --destDir <dir>              - The destination you'd like your files\n";
	print "    --releaseType <nightly/release>- Whether you're building a 'release' package, \n";
	print "        (optional)                 or you're building a nightly-style package\n";
	print "\n";
	print "--- Building a Linux Tarball\n";
	print "    --build tarball <required opts above>\n";
	print "    --destName <filename>        - The name of the tarball you would like to\n";
	print "       (optional)                  have made. Do not include the .tar.gz/tgz,\n";
	print "                                   it will be appended automatically.\n";
	print "    --freebsd (optional)         - Build a package with only FreeBSD 7.2 binaries\n";
	print "    --arm (optional)             - Build a package with only ARM Linux binaries\n";
	print "    --ppc (optional)             - Build a package with only PPC Linux binaries\n";
	print "    --encore (optional)          - Build a package for the Musical Fidelity Encore\n";
	print "    --noCPAN (optional)          - Build a package with no CPAN modules included\n";
	print "    --noCPAN-light (optional)    - Build a package with no CPAN modules, web templates etc. included\n";
	print "\n";
	print "--- Building a Docker image (with only ARM and x86_64 Linux binaries)\n";
	print "    --build docker <required opts above>\n";
	print "    --tag <tag>                  - additional comma separated tag(s) for the Docker image\n";
	print "\n";
	print "--- Building an RPM package\n";
	print "    --build rpm <required opts above>\n";
	print "\n";
	print "--- Building a Debian Package\n";
	print "    --build debian <required opts above>\n";
	print "    --fakeroot (optional)        - Whether to use fakeroot to run the build or not. \n";
	print "    --arm (optional)             - Build a package with only ARM Linux binaries\n";
	print "    --x86_64 (optional)          - Build a package with only x86_64 Linux binaries\n";
	print "    --i386 (optional)            - Build a package with only i386 Linux binaries\n";
	print "\n";
	print "--- Building a macOS menu bar item\n";
	print "    --build macos <required opts above>\n";
	print "    --destName <filename>        - The name of the OSX Package Name, do not \n";
	print "       (optional)                  include the extension.\n";
}

sub removeExclusions {
	my ($dirsToExclude, $dirsToInclude) = @_;

	## First, lets make sure we get rid of the files we don't need for this install
	my @dirsToExclude = split(/ /, $dirsToExclude);
	my $n = 0;

	$dirsToInclude ||= '';
	if ($dirsToInclude) {
		$dirsToInclude =~ s/ /\|/g;
		$dirsToInclude = "| grep -v -E '$dirsToInclude'" if $dirsToInclude;
	}

	while ($dirsToExclude[$n]) {
		my $doInclude = '';

		# exclusions with a trailing ! should respect inclusions
		if ($dirsToExclude[$n] =~ s/!$//) {
			$doInclude = $dirsToInclude;
		}

		print "INFO: Removing $dirsToExclude[$n] files from buildDir...\n";
		system("find $buildDir -depth | grep '$dirsToExclude[$n]' $doInclude | xargs rm -rf > /dev/null 2>&1");
		$n++;
	}
}

##############################################################################################
## Build Docker image                                                                       ##
##############################################################################################
sub buildDockerImage {
	removeExclusions($dirsToExcludeForDocker);

	my $dockerDir = "$buildDir/platforms/Docker";
	my $workDir = "$buildDir/server";

	## Make the image...
	print "INFO: Building Docker image with source from $workDir...\n";
	system("cp $dockerDir/.dockerignore $dockerDir/* $workDir");

	my @tags = ("$version");
	$tag ||= "rc" if $releaseType eq "release";

	# Split the tag into multiple tags if commas are present
	if ($tag) {
		my @split_tags = split(/,/, $tag);
		push @tags, @split_tags;
	}

	my $tags = join(' ', map {
		" --tag lmscommunity/$defaultDestName:$_";
	} @tags);

	system("cd $workDir; docker buildx build --push --platform linux/arm/v7,linux/amd64,linux/arm64/v8 $tags .");

	die('Docker build failed') if $? & 127;
}

##############################################################################################
## Here we can build a no-cpan tarball, if we either need one, or the user calls for one    ##
##############################################################################################
sub buildTarball {
	my ($dirsToExclude, $tarballName, $dirsToInclude) = @_;

	## Grab the variables passed to us...
	if ( ($dirsToExclude && $tarballName) || die("Problem: Not all of the variables were passed to the BuildTarball function...") ) {

		removeExclusions($dirsToExclude, $dirsToInclude);

		## We want a pretty name as the output dir, so we rename the server directory real quick
		## (the old script would do an rsync here, but an rsync takes too long and is an unnecessary waste of space, even temorarily)
		my ($name, $path, $suffix) = fileparse($tarballName);
		system("mv $buildDir/server $buildDir/$name");

		## Make the tarball...
		print "INFO: Building $tarballName.tgz with source from $buildDir/$name ($buildDir/server), excluding [$dirsToExclude]...\n";
		system("cd $buildDir; tar -zcf $tarballName.tgz $name");

		## Remove the link
		system("mv $buildDir/$name $buildDir/server");
	}
}

sub buildZIPArchive {
	my ($dirsToExclude, $zipName, $dirsToInclude) = @_;

	## Grab the variables passed to us...
	if ( ($dirsToExclude && $zipName) || die("Problem: Not all of the variables were passed to the BuildZIPArchive function...") ) {

		removeExclusions($dirsToExclude, $dirsToInclude);

		## We want a pretty name as the output dir, so we rename the server directory real quick
		## (the old script would do an rsync here, but an rsync takes too long and is an unnecessary waste of space, even temorarily)
		my ($name, $path, $suffix) = fileparse($zipName);
		system("mv $buildDir/server $buildDir/$name");

		## Make the tarball...
		print "INFO: Building $zipName.zip with source from $buildDir/$name ($buildDir/server), excluding [$dirsToExclude]...\n";
		system("cd $buildDir; zip -r $zipName.zip $name");

		## Remove the link
		system("mv $buildDir/$name $buildDir/server");
	}
}

##############################################################################################
## Build an RPM package									    ##
##############################################################################################
sub buildRPM {
	require File::Which;

	print "INFO: Building YUM-ified RPM for RHEL/RedHat/Fedora/etc... \n";

        # this must be a unix system
        # make the RPM if appropriate

        if (!File::Which::which('rpmbuild')) {

                print "rpmbuild not detected on this system. Not making an RPM";
                return;
        }

	print "INFO: Building xxx RPM in $buildDir... final file will be in $destDir. \n";

	## We need to setup an RPM build directory to put all of our files in...
	for my $path (qw(SPECS SOURCES BUILD RPMS SRPMS)) {
		print "INFO: Making directory for RPM build... ($buildDir/rpm/$path)\n";
		mkpath("$buildDir/rpm/$path") || die "PROBLEM: I couldn't create $buildDir/rpm/$path...\n";
	}

	## Now we need to build a tarball ...
	print "INFO: Building $buildDir/$defaultDestName.tgz for the RPM...\n";

	# CentOS 7 is still supported till 2024 - put 5.16 back in...
	$dirsToExcludeForLinuxPackage =~ s/5\.16 //;

	buildTarball($dirsToExcludeForLinuxPackage, "$buildDir/$defaultDestName");

	## We already built a tarball, so now lets use it...
	print "INFO: Moving $buildDir/$defaultDestName.tgz to $buildDir/rpm/SOURCES...\n";
	system("mv $buildDir/$defaultDestName.tgz $buildDir/rpm/SOURCES");

	## Copy the various SPEC< Config, etc files into the right dirs...
        copy("$buildDir/platforms/redhat/lyrionmusicserver.config", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/lyrionmusicserver.init", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/lyrionmusicserver.logrotate", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/lyrionmusicserver.service", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/README.systemd", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/README.rebranding", "$buildDir/rpm/SOURCES");
        copy("$buildDir/platforms/redhat/lyrionmusicserver.spec", "$buildDir/rpm/SPECS");

	## Just check, if this is a 'nightly' build, pass on 'trunk' to the rpmbuild command
	if ($releaseType eq "nightly") {
		$releaseType = "trunk";
	}

        # Do it
        my $date = strftime('%Y-%m-%d', localtime());
        print `rpmbuild -bb --with $releaseType --define="src_basename $defaultDestName" --define="_version $version" --define="_src_date $date" --define="_revision $revision" --define='_topdir $buildDir/rpm' $buildDir/rpm/SPECS/lyrionmusicserver.spec`;

	## Just move the file out of the building directory, and put it into the destDir
	print "INFO: Moving $buildDir/rpm/RPMS/noarch/*.rpm to $destDir\n";
	system("mv $buildDir/rpm/RPMS/noarch/*.rpm $destDir");

	rmtree("$buildDir/rpm");
}


##############################################################################################
## Build a Debian package								    ##
##############################################################################################
sub buildDebian {
	print "INFO: Building package for Debian Release... \n";

	my $suffix;
	if ($arm) {
		print "INFO: This is an ARM Debian build.\n";
		removeExclusions($dirsToExcludeForARMDeb);
		$suffix = 'arm';
	}
	elsif ($x86_64) {
		print "INFO: This is a x86_64 Debian build.\n";
		removeExclusions($dirsToExcludeForx86_64Deb);
		$suffix = 'amd64';
	}
	elsif ($i386) {
		print "INFO: This is an i386 Debian build.\n";
		removeExclusions($dirsToExcludeFori386Deb);
		$suffix = 'i386';
	}
	else {
		removeExclusions($dirsToExcludeForLinuxPackage);
	}

	## Lets setup the right version/build #...
	open (READ, "$sourceDir/platforms/debian/changelog") || die "Can't open changelog file to read: $!\n";
	open (WRITE, ">$buildDir/platforms/debian/changelog") ||  die "Can't open changelog file to write: $!\n";

	## Unlike the RPM, with a Debian package there's no simple way to go from a
	## 'release' to a 'nightly.' We need to make that choice here, and update
	## the changelog file accordingly.

	if ($releaseType eq "nightly") {
		$release = "$version~$revision";
	} elsif ($releaseType eq "release") {
		$release = "$version";
	}

	while (<READ>) {
		s/_VERSION_/$release/;
		print WRITE $_;
	}

	close WRITE;
	close READ;

	## Ok, we've set everything up... lets run the dpkg-buildpkg command...
	if ($fakeRoot) {
		print `cd $buildDir/platforms; fakeroot dpkg-buildpackage -b -d -Zxz ;`;
	} else {
		print `cd $buildDir/platforms; dpkg-buildpackage -b -d -Zxz ;`;
	}

	if ($suffix) {
		my ($old) = glob("$buildDir/*all.deb");
		my $new = $old;
		$new =~ s/_all\.deb/_$suffix.deb/;
		rename $old, $new;
	}

	## Now that the package is built, lets put it into the destDir
	system("mv -f $buildDir/*.deb $destDir");

}


##############################################################################################
## Build the macOS package
##############################################################################################
sub buildMacOS {
	## Grab the variables passed to us...
	if ( ($_[0] ) || die("Problem: Not all of the variables were passed to the buildMacOS function...") ) {
		## Take the filename passed to us and make sure that we build the PKG with
		## that name, and that the 'pretty mounted name' also matches
		my $pkgName = $_[0];

		print "INFO: Building package for macOS (Universal)... \n";

		## First, lets make sure we get rid of the files we don't need for this install
		foreach (split(/ /, $dirsToExcludeForMacOS)) {
			print "INFO: Removing $_ files from buildDir...\n";
			system("find $buildDir | grep -i $_ | xargs rm -rf ");
		}
		system("rm -f $destDir/*.dmg");

		## Copy in the documentation and license files..
		print "INFO: Copying documentation & licenses...\n";
		copy("$buildDir/server/license.txt", "$buildDir/$pkgName/License.txt");

		system("cd \"$buildDir\"; mkdir perl; cd perl; tar xjf \"$buildDir/platforms/osx/Perl-5.34.0-x86_64-arm64.tar.bz2\"; chmod a+x bin/perl");

		my $realName = $pkgName;
		$realName =~ s/-.*//;
		$realName =~ s/(.)([A-Z])/$1 $2/g;
		print "INFO: Building $realName.app with source from $buildDir/$pkgName...\n";

		# prepare the launcher app
		my @args = (
			'--name', 'Lyrion Music Server',
			'--interface-type', 'None',
			'--author', 'Lyrion Community, Michael Herger',
			'--app-version', $version,
			'--app-icon', "$buildDir/platforms/osx/MenuBarItem/icon.icns",
			'--quit-after-execution',
			'--overwrite',
			"$buildDir/platforms/osx/MenuBarItem/LauncherHelper.sh",
			"$destDir/$realName.app"
		);

		system("rm -rf '$destDir/$realName.app'");
		system('platypus', @args);

		@args = (
			'--name', 'Lyrion Music Server',
			'--interface-type', 'Status Menu',
			'--author', 'Lyrion Community, Michael Herger',
			'--app-version', $version,
			'--app-icon', "$buildDir/platforms/osx/MenuBarItem/icon.icns",
			'--status-item-kind', 'Icon',
			'--status-item-icon', "$buildDir/platforms/osx/MenuBarItem/iconTemplate.icns",
			'--status-item-template-icon',
			'--status-item-sysfont',
			'--interpreter', '../MacOS/perl',
			'--background',
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/LMSMenuAction.pm",
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/LMSMenu.json",
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/start-server.sh",
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/stop-server.sh",
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/create-launchitem.sh",
			'--bundled-file', "$buildDir/platforms/osx/MenuBarItem/remove-launchitem.sh",
			'--bundled-file', "$buildDir/server",
			'--overwrite',
			"$buildDir/platforms/osx/MenuBarItem/LMSMenu.pl",
			"$buildDir/$pkgName"
		);

		system('platypus', @args);

		# binaries have to live in the MacOS folder, or notarization will fail!
		# https://developer.apple.com/documentation/bundleresources/placing_content_in_a_bundle
		# https://developer.apple.com/documentation/xcode/embedding-nonstandard-code-structures-in-a-bundle
		move("$buildDir/perl/bin/perl", "$buildDir/$pkgName.app/Contents/MacOS/perl");
		system("cp -R '$buildDir/perl/lib' '$buildDir/$pkgName.app/Contents/'");
		system("cd '$buildDir/$pkgName.app/Contents/Resources/server/Bin/darwin' && rm -f mac; mv * '$buildDir/$pkgName.app/Contents/MacOS'");

		# copy the menu bar item inside the launcher
		system("cd $buildDir && mv '$pkgName.app' '$destDir/$realName.app/Contents/MacOS/$realName.app'");

		# see whether we have certificates to sign the binaries
		# "$ENV{HOME}/Library/Developer/Xcode/UserData/Provisioning\ Profiles/build_pp.provisionprofile";
		my $hasCerts;
		if ( $ENV{BUILD_CERTIFICATE_BASE64} && $ENV{DEV_CERT_NAME} ) {
			$hasCerts = 1;
			print "INFO: Signing $realName.app...\n";
			# we must --force the signature to replace existing signatures
			# the menu bar item is inside the launcher, so we need to sign it twice
			system("cd '$destDir/$realName.app/Contents/MacOS/$realName.app/Contents/MacOS/'; ls | grep -v Server | xargs codesign -s \"$ENV{DEV_CERT_NAME}\" -o runtime --force ");
			system("cd '$destDir/$realName.app/Contents/MacOS/'; codesign -s \"$ENV{DEV_CERT_NAME}\" -o runtime '$realName.app'");
			system("codesign -v -s \"$ENV{DEV_CERT_NAME}\" -o runtime '$destDir/$realName.app'");
		}

		# if we have NodeJS installed, try to create a DMG file - see https://github.com/sindresorhus/create-dmg
		if (`which npx`) {
			print "INFO: Building $pkgName.dmg using $realName.app...\n";
			# system("cd $destDir; npx --yes create-dmg --overwrite '$realName.app'; mv -f L*.dmg '$pkgName.dmg'");
			system("cd $buildDir/platforms/osx/MenuBarItem && cp *png *webloc icon.icns app.json $destDir/");

			# add signing information if available
			if ($hasCerts) {
				system("sed -e 's/_SIGNING_IDENTITY_/$ENV{DEV_CERT_NAME}/' $buildDir/platforms/osx/MenuBarItem/app.json > $destDir/app.json");
			}
			else {
				system("grep -v _SIGNING_IDENTITY_ $buildDir/platforms/osx/MenuBarItem/app.json > $destDir/app.json");
			}

			system("cd $destDir; npx --yes appdmg\@0.6.6 app.json LMS.dmg; mv -f LMS.dmg '$pkgName.dmg'");
			system("cd $destDir; rm -rf *.png icon.icns app.json *webloc L*.app");

			if ($hasCerts) {
				print "INFO: Notarizing $pkgName.dmg...";
				system("xcrun notarytool submit '$destDir/$pkgName.dmg' --progress --apple-id=$ENV{APPLE_ID} --password=$ENV{NOTARIZATION_PW} --team-id=$ENV{TEAM_ID} --wait");
				system("xcrun stapler staple '$destDir/$pkgName.dmg'");
			}
		}
		else {
			print "INFO: we're missing the necessary tools to build the DMG package.";
		}
	}
}


##############################################################################################
## Build the Windows64 Installer
##############################################################################################
sub buildWin64 {
	## Grab the variables passed to us...
	if ( ($_[0] ) || die("Problem: Not all of the variables were passed to the BuildWin64 function...") ) {
		## Take the filename passed to us and make sure that we build the DMG with
		## that name, and that the 'pretty mounted name' also matches
		my $destFileName = $_[0];

		if ( $releaseType && $releaseType eq "release" ) {
			$destFileName =~ s/-$revision//;
		}

		print "INFO: Building Win64 Installer Package...\n";

		## First, lets make sure we get rid of the files we don't need for this install
		foreach (split(/ /, $dirsToExcludeForWin64)) {
			print "INFO: Removing $_ files from buildDir...\n";
			system("find $buildDir | grep -i $_ | xargs rm -rf ");
		}
		rmtree("$buildDir/build/server/t");

		print "INFO: Creating $buildDir/build for the final packaging...\n";
		mkpath("$buildDir/build");

		print "INFO: Copying server directory to $buildDir/build...\n";
		system("cp -R $buildDir/server \"$buildDir/build/server\" ");

		print "INFO: Copying various documents to $buildDir/build...\n";
		copy("$buildDir/server/license.txt", "$buildDir/build/License.txt");

		my $rev = int(($revision || getRevisionForRepo() || $version) / 3600) % 65536;

		print "INFO: Making installer...\n";

		copy("$buildDir/platforms/win32/installer/ServiceEnabler.iss", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/StartupModeWizardPage.iss", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/ServiceManager.iss", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/SocketTest.iss", "$buildDir/build") || die ($!);
		copy("$buildDir/platforms/win32/installer/strings.iss", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/psvince.dll", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/sockettest.dll", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/ApplicationData.xml", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/instsvc.pl", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/7z.exe", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/7z.dll", "$buildDir/build");
		copy("$buildDir/platforms/win32/res/SqueezeCenter.ico", "$buildDir/build");
		copy("$buildDir/platforms/win32/res/SqueezeCenterOff.ico", "$buildDir/build");
		copy("$buildDir/server/Bin/MSWin32-x64-multi-thread/grant.exe", "$buildDir/build");

		# Swedish is 3rd party - we keep it in our installer folder
		copy("$buildDir/platforms/win32/installer/Swedish.isl", "$buildDir/build");

		copy("$buildDir/platforms/win32/installer/logo.bmp", "$buildDir/build");
		copy("$buildDir/platforms/win32/installer/squeezebox.bmp", "$buildDir/build");

		# replacing build number in installer script
		system("sed -e \"s/VersionInfoVersion=0.0.0.0/VersionInfoVersion=$rev/\" \"$buildDir/platforms/win32/installer/SqueezeCenterX64.iss\" > \"$buildDir/build/SqueezeCenter.iss\"");
		# don't use slashes (eg. /Q) in parameters - it confused bash on Github
		system("cd $buildDir/build; \"$buildDir/platforms/win32/InnoSetup/ISCC.exe\" -Q ServiceEnabler.iss");
		system("cd $buildDir/build; \"$buildDir/platforms/win32/InnoSetup/ISCC.exe\" -Q SqueezeCenter.iss");

		print "INFO: Everything is finally ready, renaming the .exe and zip files...\n";
		print "INFO: Moving [$buildDir/build/Output/SqueezeSetup.exe] to [$destDir/$destFileName.exe]\n";
		move("$buildDir/build/Output/SqueezeSetup64.exe", "$destDir/$destFileName.exe");

		rmtree("$buildDir/build");
	}
}

##i############################################################################################
## Ok, start the main() function and begin everything...				    ##
##############################################################################################
main();
