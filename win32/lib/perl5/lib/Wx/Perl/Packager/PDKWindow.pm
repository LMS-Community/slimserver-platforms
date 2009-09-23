package Wx::Perl::Packager::PDKWindow;
use Wx::Perl::Packager;
use Wx::Perl::Packager::Utils;
use Wx qw( :everything );
use strict;
use base qw(Wx::Frame);
use vars qw($VERSION);
$VERSION = 0.15;

our $debugprinton = $ENV{WXPERLPACKAGER_DEBUGPRINT_ON} || 0;
          
use Wx::Event qw(   EVT_MENU EVT_CLOSE 
                    EVT_BUTTON );

my($ID_MENU_FILE_EXIT)=(5);

use Win32;

sub new{
   if(not exists $_[3]){ $_[3] = 'Wx::Perl::Packager  PDK Helper';}
   if(not exists $_[4]){ $_[4] = wxDefaultPosition;}
   if(not exists $_[5]){ $_[5] = wxDefaultSize;}
   if(not exists $_[6]){ $_[6] = wxDEFAULT_FRAME_STYLE;}
   my( $this ) = shift->SUPER::new( @_ );
   $this->initBefore();
   $this->Show(0);
   EVT_CLOSE($this,\&OnClose);
   $this->{MenuBar}= Wx::MenuBar->new;
   $this->{mnuFile}=Wx::Menu->new;
   $this->{MenuBar}->Append($this->{mnuFile},'File');
   my($itemmenu) = Wx::MenuItem->new($this->{mnuFile},$ID_MENU_FILE_EXIT,"Exit",'',0);
   $this->{mnuFile}->AppendItem($itemmenu);
   $this->SetMenuBar($this->{MenuBar});
   EVT_MENU($this,$ID_MENU_FILE_EXIT,\&OnMnuFileExit);
   $this->{pnlMain} = Wx::Panel->new($this,-1,[0,0],[426,221],wxNO_BORDER|wxTAB_TRAVERSAL);
   $this->{lblMain} = Wx::StaticText->new($this->{pnlMain},-1,"",[10,10],[368,41],wxST_NO_AUTORESIZE);
   $this->{lblMain}->SetLabel('This PDK helper will prepare a default .perlapp file with the necessary bound wxPerl DLLs.');
   $this->{btnCreate} = Wx::Button->new($this->{pnlMain},-1,"",[267,84],[80,22]);
   $this->{btnCreate}->SetLabel('Create File');
   EVT_BUTTON($this,$this->{btnCreate},\&OnBtnCreate);
   $this->{szvFrame} = Wx::BoxSizer->new(wxVERTICAL);
   $this->{szvPanelMain} = Wx::BoxSizer->new(wxVERTICAL);
   $this->{szButton} = Wx::BoxSizer->new(wxHORIZONTAL);
 
   $this->{szvFrame}->Add($this->{pnlMain},1,wxTOP|wxLEFT|wxBOTTOM|wxRIGHT|wxEXPAND|wxADJUST_MINSIZE,0);
   $this->{szvPanelMain}->Add($this->{lblMain},0,wxTOP|wxLEFT|wxBOTTOM|wxRIGHT|wxEXPAND,10);
   $this->{szvPanelMain}->Add($this->{szButton},1,wxTOP|wxLEFT|wxBOTTOM|wxRIGHT|wxALIGN_RIGHT,4);
   $this->{szButton}->Add($this->{btnCreate},0,wxTOP|wxLEFT|wxBOTTOM|wxRIGHT|wxALIGN_BOTTOM,3);
   $this->SetSizer($this->{szvFrame});$this->SetAutoLayout(1);$this->Layout();
   $this->{pnlMain}->SetSizer($this->{szvPanelMain});$this->{pnlMain}->SetAutoLayout(1);$this->{pnlMain}->Layout();
   $this->Refresh();
   $this->initAfter();
   return $this;
}


sub OnBtnCreate{ 
   my( $this,$event) = @_;
   $this->Close() if !$this->create_perlapp();
} 

sub OnClose{ 
   my( $this,$event) = @_;
   $event->Skip(1);
   $this->Destroy;

} 

sub OnMnuFileExit{
   my( $this,$event) = @_;
   $this->Close;
} 

sub initBefore{
   my( $this) = @_;
   $this->{CONFDATA} = {};
}
sub initAfter{
    my( $this) = @_;
    $this->app_initialise;
    $this->SetIcon( Wx::Icon->new($this->packager_path() . 'packager.ico', wxBITMAP_TYPE_ICO) ); 
    $this->Centre;
    $this->Show(1);
}

sub app_initialise {
    my $this = shift;
    foreach ( @INC ) {
        my $path = "$_/Wx/Perl/Packager/packager.ico";
        if( -e  $path) {
          $path =~ s/packager\.ico$//;
          $this->packager_path($path);
          last;
        }
    }
    
}

sub packager_path {
    my $this = shift;
    if(@_) { $this->{CONFDATA}->{packager_path} = shift; }
    return $this->{CONFDATA}->{packager_path};
}

sub create_perlapp {
    my $this = shift;
    
    my $scriptname = $this->get_file_name() or die qq(did not select script to package);
    my $perlapp = $this->get_perlapp_name($scriptname) or die qq(did not select perlapp file for output);
    
    my @libfiles = Wx::Perl::Packager::get_wxboundfiles();
    
    Wx::Perl::Packager::Utils::create_perlapp_content(\@libfiles, $scriptname, $perlapp);
    
    #launch perlapp
    my $paipath = Wx::Perl::Packager::Utils::get_perlapp_execpath();
    $paipath = Win32::GetShortPathName($paipath);
    my $pdkcmd = '--packer ../perlapp.exe "' . $perlapp . '"';
    #print qq(Running $paipath $pdkcmd ....\n\n);
    #system($paipath, $pdkcmd);
    wxTheApp->PDKExec($paipath);
    wxTheApp->PDKParams($pdkcmd);
    $this->Close();
 
}

sub get_file_name {
    my $this = shift;
    my $filepath = undef;
    
    my $flags;
    
    if ( Wx::wxVERSION() < 2.008000 ) {
        $flags = wxOPEN|wxFILE_MUST_EXIST|wxCENTRE;
    } else {
        $flags = wxFD_OPEN|wxFD_FILE_MUST_EXIST;
    }
    
    
    my $dialog = Wx::FileDialog->new
        ( $this, "Select a Perl script to package", '', '',
                 "Perl Scripts (*.pl, *.pm)|*.pl;*.pm|All Files (*.*)|*.*",
                  $flags );
        
    if( $dialog->ShowModal != wxID_CANCEL ) {
        $filepath = $dialog->GetPath;
    }
    $dialog->Destroy;
    return $filepath;
}

sub get_perlapp_name {
    my $this = shift;
    my $filepath = shift;
    
    my @paths = split(/[\\\/]/, $filepath);
    my $filename = pop(@paths);
    
    $filename =~ s/\.[^\.]*$//;
    $filename .= '.perlapp';
    
    my $directory = join('/', @paths);
    
    my $flags;
        
    if ( Wx::wxVERSION() < 2.008000 ) {
        $flags = wxSAVE|wxOVERWRITE_PROMPT|wxCENTRE;
    } else {
        $flags = wxFD_SAVE|wxFD_OVERWRITE_PROMPT;
    }
    
    
    my $dialog = Wx::FileDialog->new
        ( $this, "Select a name for the perlapp file", '', '',
                 "PerlApp file (*.perlapp)|*.perlapp",
                  $flags );
    
    $dialog->SetDirectory($directory);
    $dialog->SetFilename($filename);
    $dialog->SetPath($directory . '/' . $filename);
    
        
    if( $dialog->ShowModal != wxID_CANCEL ) {
        $filepath = $dialog->GetPath;
    }
    $dialog->Destroy;
    return $filepath;
}

sub cancel_message {
    my ($this, $msg) = @_;
    my $message = $msg . qq(\n\nDo you wish to exit the Wx::Perl::Packager PDK utility?);
    if(Wx::MessageBox($message,
                      "Wx::Perl::Packager PDK Utility", 
                      wxYES_NO|wxICON_QUESTION|wxCENTRE, $this) == wxYES) {
        return 1;
    } else {
        return 0;
    }
   
}

sub __debugprint {
    my ($item, $data) = @_;
    return if(!$debugprinton);
    print qq($item: $data\n);
}




__END__

1;
