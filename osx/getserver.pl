#!/usr/bin/perl

$distdir = 		 'build/SLIMP3 Server.app/Contents/server';

print "Removing old: $distdir\n";
system "rm -rf '$distdir'";

print "Copying: $distdir\n";
system "cp -Rf ../../server '$distdir'";
system "chmod a+x '$distdir/slimserver.pl'";

print "Copying: $distdir/firmware\n";
system "mkdir '$distdir/firmware'";
system "cp ../../bootload/update_firmware.pl '$distdir/firmware'";
system "cp ../../bootload/MAIN.HEX '$distdir/firmware'";

die "copy failed" unless (-d $distdir);
die "copy failed" unless (-d $distdir . "/firmware");

open FIND, 'find \''.$distdir.'\' -name CVS -type d -print|';

while ($cvsdir=<FIND>) {
  chomp ($cvsdir);
  print "Deleting CVS: $cvsdir\n";
  `rm -rf '$cvsdir'`;
}
close FIND; 

open FIND, 'ls  \''.$distdir.'/CPAN/arch\'|';
while ($arches=<FIND>) {
  chomp ($arches);
  if ($arches !~ /darwin/) {
	  $thepath = $distdir.'/lib/CPAN/arch/'.$arches;
	  print "Deleting non-darwin arch stuff: $thepath\n";
	  `rm -rf '$thepath'`;
  }
}

#delete useless stuff
print "Deleting: $distdir/misc\n";
`rm -rf '$distdir/misc'`;

print "Deleting: $distdir/lib-slimp3\n";
`rmdir '$distdir/lib-slimp3'`;
