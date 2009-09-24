package Wx::Perl::Packager::Utils;
use strict;
use Win32::TieRegistry( Delimiter=>"/", qw( REG_SZ
                                            REG_EXPAND_SZ
                                            REG_DWORD
                                            REG_BINARY
                                            REG_MULTI_SZ
                                            KEY_READ
                                            KEY_WRITE
                                            KEY_ALL_ACCESS ));   

our $VERSION = '0.15';

our $debugprinton = $ENV{WXPERLPACKAGER_DEBUGPRINT_ON} || 0;

sub create_perlapp_content {
    my ($libfiles, $filepath, $apppath) = @_;
    # Check where PerlApp is installed
    
    my $paipath = get_perlapp_execpath();
    my $perlappversion = get_perlapp_version($paipath);
    
    my @libfiles = @$libfiles;
    
    if( $perlappversion >= 7.1 ) {
        # reduce libfiles
        @libfiles = grep{ $_->{file} =~ /gdiplus\./ } @$libfiles;
    }
    
    my $packerpath = $paipath;
    $packerpath =~ s/pai\.exe$/perlapp\.exe/;
    
    __debugprint('PERLAPP', $packerpath);
    __debugprint('PAI', $paipath);
    __debugprint('PERLAPP VERSION', $perlappversion);
    
    if(!$paipath) { die 'Unable to locate path to PerlApp executable'; }
    
    my @paths = split(/[\\\/]/, $filepath);
    my $scriptname = pop(@paths);
      
    my $scriptdir = join("\\", @paths);
    
    
    
    # WRITE FILE
    open(FILE, ">$apppath") or die qq(Failed opening perlapp file $apppath: $!);
    
    print FILE '#!' . $paipath . "\n";
    print FILE 'PAP-Version: 1.0' . "\n";
    
    print FILE 'Packer: ' . $packerpath . "\n";
    print FILE 'Script: ' . $scriptname . "\n";
    print FILE 'Cwd: ' . $scriptdir . "\n";
    
    foreach my $lfile (@libfiles) {
        my $bindline = 'Bind: ' . $lfile->{boundfile} . '[file=';
        $bindline .= $lfile->{file};
        $bindline .= ',extract' if $lfile->{autoextract}; 
        $bindline .= ',mode=444]' . "\n";
        print FILE $bindline;
    }
    
    print FILE 'Clean: 0' ."\n";
        
    # create a datestamp
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon += 1;

    my $datestamp = qq($year-);
    $datestamp .= sprintf("%02d", $mon) . '-' . sprintf("%02d", $mday);
    $datestamp .= ' ' . sprintf("%02d", $hour) . ':' . sprintf("%02d", $min) . ':' . sprintf("%02d", $sec);
    print FILE 'Date: ' . $datestamp . "\n";
    print FILE 'Debug: ' . "\n";
    print FILE 'Dependent: 0' . "\n";
    print FILE 'Dyndll: 0' . "\n";
    
    my $execname = $scriptname;
    $execname =~ s/(\.pl|\.pm)$/\.exe/;
    
    print FILE 'Exe: ' . $execname . "\n";
    print FILE 'Force: 0' . "\n";
    print FILE 'Gui: 1' . "\n";
    
    # GET THE HOSTAME
       
    print FILE 'Hostname: ' . lc(Win32::NodeName()) . "\n";
    print FILE 'No-Compress: 0' . "\n";
    print FILE 'No-Logo: 0' . "\n";
    print FILE 'Runlib: ' . "\n";
    print FILE 'Shared: none' . "\n";
    print FILE 'Tmpdir: ' . "\n";
    print FILE 'Verbose: 0' . "\n";
    print FILE 'Version-Comments: ' . "\n";
    print FILE 'Version-CompanyName: ' . "\n";
    print FILE 'Version-FileDescription: ' . "\n";
    print FILE 'Version-FileVersion: ' . "\n";
    print FILE 'Version-InternalName: ' . "\n";
    print FILE 'Version-LegalCopyright: ' . "\n";
    print FILE 'Version-LegalTrademarks: ' . "\n";
    print FILE 'Version-OriginalFilename: ' . "\n";
    print FILE 'Version-ProductName: ' . "\n";
    print FILE 'Version-ProductVersion: ' . "\n";
    print FILE 'Xclude: 0' . "\n";
    
    close(FILE);
}

sub create_argfile_content {
    my ($libfiles, $filepath ) = @_;
    
    my $perlappversion = get_perlapp_version();
    
    my @libfiles = @$libfiles;
    
    if( $perlappversion >= 7.1 ) {
        # reduce libfiles
        @libfiles = grep{ $_->{file} =~ /gdiplus\./ } @$libfiles;
    }
    
    # WRITE FILE
    open(FILE, ">$filepath") or die qq(Failed opening args file $filepath: $!);
    
    for my $lfile (@libfiles) {
        my $bindline = '--bind ' . $lfile->{boundfile} . '[file=';
        $bindline .= $lfile->{file};
        $bindline .= ',extract' if $lfile->{autoextract}; 
        $bindline .= ',mode=444]' . "\n";
        print FILE $bindline;
    }
    
    close(FILE);
}



sub get_perlapp_execpath {
    my $pai;
    
    # regkeys perl_auto_file / Perlapp.Project to return pai.exe or perlapp.exe
    
    my @keys = qw( Perlapp.Project perlapp_auto_file );
    #my @keys = qw( perlapp_auto_file Perlapp.Project );
    
    for (@keys) {  
        my $regkey= $Registry->{"HKEY_CLASSES_ROOT/$_/Shell/Open/Command/"};
       
        my $path = $regkey->{"/"};
        if($path =~ /^"([^"]*)/) {
            my $filepath = $1;
            $filepath =~ s/perlapp.exe$/lib\\pai.exe/i;
            $pai = $filepath;
            last;
        }
    }
    if($pai && -e $pai) {
        return $pai;
    } else {
        # try program file dirs
        
        my $progfiledir = $ENV{PROGRAMFILES};
        
        opendir(PROGDIR, $progfiledir) or die qq(Could not open $progfiledir: $!);
        my @asdirs = grep{ /^ActiveState Perl Dev Kit/ && -d "$progfiledir\\$_" } readdir(PROGDIR);
        closedir(PROGDIR);       
        
        #my @files = ( "$ENV{PROGRAMFILES}\\ActiveState Perl Dev Kit 7.0\\bin\\lib\\pai.exe", "$ENV{PROGRAMFILES}\\ActiveState Perl Dev Kit 6.0\\bin\\lib\\pai.exe" );
        my @progdirpaths = sort {$b cmp $a} @asdirs;
        for my $asdir (@progdirpaths) {
            my $file = qq($asdir\\bin\\lib\\pai.exe);
            if( -e $file) {
                $pai = $file;
                last;
            }
        }
    }
    
    if($pai && -e $pai) {
        return $pai;
    } else {
        return undef;
    }
}

sub get_perlapp_version {
    my $execpath = shift || get_perlapp_execpath();
    my $perlappversion = undef;
    
    if( $execpath =~ /ActiveState Perl Dev Kit ([\d\.]+)/) {
        $perlappversion = $1;
    }
    return $perlappversion;
}

sub __debugprint {
    my ($item, $data) = @_;
    return if(!$debugprinton);
    print qq($item: $data\n);
}


1;
