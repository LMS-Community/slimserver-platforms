#############################################################################
## Name:        Wx.pm
## Purpose:     main wxPerl module
## Author:      Mattia Barbon
## Modified by:
## Created:     01/10/2000
## RCS-ID:      $Id: Wx.pm 2521 2009-01-19 20:03:02Z mbarbon $
## Copyright:   (c) 2000-2009 Mattia Barbon
## Licence:     This program is free software; you can redistribute it and/or
##              modify it under the same terms as Perl itself
#############################################################################

package Wx;

use strict;
require Exporter;

use vars qw(@ISA $VERSION $XS_VERSION $AUTOLOAD @EXPORT_OK %EXPORT_TAGS
  $_platform $_universal $_msw $_gtk $_motif $_mac $_x11 $_static);

$_msw = 1; $_gtk = 2; $_motif = 3; $_mac = 4; $_x11 = 5;

@ISA = qw(Exporter);
$VERSION = '0.90';
$XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

sub BEGIN{
  @EXPORT_OK = qw(wxPOINT wxSIZE wxTheApp);
  %EXPORT_TAGS = ( );
}

#
# utility functions
#
sub wxPOINT  { Wx::Point->new( $_[0], $_[1] ) }
sub wxSIZE   { Wx::Size->new( $_[0], $_[1] )  }
sub wxTheApp { $Wx::wxTheApp }

sub AUTOLOAD {
  my( $constname );

  ($constname = $AUTOLOAD) =~ s<^.*::>{};
  return 0 if $constname eq 'wxVERSION';

  my( $val ) = constant($constname, 0 );

  if ($! != 0) {
# re-add this if need support for autosplitted subroutines
#    $AutoLoader::AUTOLOAD = $AUTOLOAD;
#    goto &AutoLoader::AUTOLOAD;
    Wx::_croak( "Error while autoloading '$AUTOLOAD'" );
  }

  eval "sub $AUTOLOAD { $val }";
  goto &$AUTOLOAD;
}

# handle :allclasses specially
sub import {
  my $package = shift;
  my $count = 0;
  foreach ( @_ ) {
    m/^:/ or last;
    m/^:allclasses$/ and do {
      eval _get_packages();

      die $@ if $@;

      splice @_, $count, 1;
    };

    ++$count;
  }

  $package->export_to_level( 1, $package, @_ );
}

sub END {
  UnLoad() if defined &UnLoad;
}

sub _match(\@$;$$) { &_xsmatch( [@{shift()}],@_ ) }

sub _ovl_error {
  ( 'unable to resolve overloaded method for ', $_[0] || (caller(1))[3] );
}

sub _croak {
  require Carp;
  goto &Carp::croak;
}

# Blech! (again...)
# wxWidgets DLLs need to be installed in the same directory as Wx.dll,
# but then LoadLibrary can't find them unless they are already loaded,
# so we explicitly load them (on Win32 and wxWidgets 2.5.x+) just before
# calling Wx::wx_boot. Finding the library requires determining the path
# and the correct name
use Wx::Mini;

_start();

our( $wx_path );

sub _load_file {
  Wx::wxVERSION() < 2.005 ? DynaLoader::dl_load_file( $_[0], 0 ) :
                            Wx::_load_plugin( $_[0] );
}

my( $load_fun, $unload_fun ) = ( \&_load_dll, \&_unload_dll );

sub set_load_function { $load_fun = shift }
sub set_end_function { $unload_fun = shift }

sub load_dll {
  return if $^O eq 'darwin' || Wx::wxVERSION() < 2.005;
  goto &$load_fun;
}

sub unload_dll {
  return if $^O eq 'darwin' || Wx::wxVERSION() < 2.005;
  goto &$unload_fun;
}

END { unload_dll() }

sub _unload_dll { }

sub _load_dll {
  local $ENV{PATH} = $wx_path . ';' . $ENV{PATH} if $wx_path;
  return unless exists $Wx::dlls->{$_[0]} && $Wx::dlls->{$_[0]};
  my $dll = $Wx::dlls->{$_[0]};
  $dll = $wx_path . '/' . $dll if $wx_path;
  Wx::_load_file( $dll );
}

{
  _boot_Constant( 'Wx', $XS_VERSION );
  _boot_Events( 'Wx', $XS_VERSION );
  _boot_Window( 'Wx', $XS_VERSION );
  _boot_Controls( 'Wx', $XS_VERSION );
  _boot_Frames( 'Wx', $XS_VERSION );
  _boot_GDI( 'Wx', $XS_VERSION );
}

#
# British vs. American spelling aliases
#
*Wx::Window::Center = \&Wx::Window::Centre;
*Wx::Window::CenterOnParent = \&Wx::Window::CentreOnParent;
*Wx::Window::CenterOnScreen = \&Wx::Window::CentreOnScreen;
*Wx::ListCtrl::InsertStringImageItem = \&Wx::ListCtrl::InsertImageStringItem;
no strict 'refs';
*{"Wx::Size::y"} = \&Wx::Size::height; # work around syntax highlighting
use strict 'refs';
*Wx::Size::x = \&Wx::Size::width;

*Wx::Window::GetClientSizeWH = \&Wx::Window::GetClientSizeXY;

if( Load() ) {
    SetConstants();
    SetConstantsOnce();
    SetOvlConstants();
    SetEvents();
    SetInheritance();
}

sub END {
  UnsetConstants() if defined &UnsetConstants;
}

#
# set up wxUNIVERSAL, wxGTK, wxMSW, etc
#
eval( "sub wxUNIVERSAL() { $_universal }" );
eval( "sub wxPL_STATIC() { $_static }" );
eval( "sub wxMOTIF() { $_platform == $_motif }" );
eval( "sub wxMSW() { $_platform == $_msw }" );
eval( "sub wxGTK() { $_platform == $_gtk }" );
eval( "sub wxMAC() { $_platform == $_mac }" );
eval( "sub wxX11() { $_platform == $_x11 }" );

# Mac OS X warning
if( wxMAC() && $^X !~ m{/wxPerl\.app/} && !$ENV{HARNESS_ACTIVE} ) {
    warn "On Mac OS X please run scripts with the 'wxPerl' interpreter\n";
}

require Wx::App;
require Wx::Event;
require Wx::Locale;
require Wx::Menu;
require Wx::RadioBox;
require Wx::Timer;
require Wx::Wx_Exp;
# for Wx::Stream & co.
require Tie::Handle;

package Wx::GDIObject; # warning for non-existent package
package Wx::Object;    # likewise

#
# overloading for Wx::TreeItemId
#
package Wx;

sub _string { overload::StrVal( $_[0] ) }
sub _number { require Scalar::Util; Scalar::Util::refaddr( $_[0] ) }

package Wx::TreeItemId;

use overload '<=>'      => \&tiid_spaceship,
             'bool'     => sub { $_[0]->IsOk },
             '""'       => \&Wx::_string,
             '0+'       => \&Wx::_number,
             'fallback' => 1;

package Wx::Font;

use overload '<=>'      => \&font_spaceship,
             'bool'     => sub { $_[0]->IsOk },
             '""'       => \&Wx::_string,
             '0+'       => \&Wx::_number,
             'fallback' => 1;

#
# Various functions
#

package Wx;

# easier to implement than to wrap
sub GetMultipleChoices {
  my( $message, $caption, $choices, $parent, $x, $y, $centre,
      $width, $height ) = @_;

  my( $dialog ) = Wx::MultiChoiceDialog->new
    ( $parent, $message, $caption, $choices );

  if( $dialog->ShowModal() == &Wx::wxID_OK ) {
    my( @s ) = $dialog->GetSelections();
    $dialog->Destroy();
    return @s;
  }

  return;
}

sub LogTrace {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogTrace( $t );
}

sub LogTraceMask {
  my( $m ) = shift;
  unless( @_ ) { require Carp; Carp::carp( "No message for $m" ); }
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogTraceMask( $m, $t );
}

sub LogStatus {
  my( $t );

  if( ref( $_[0] ) && $_[0]->isa( 'Wx::Frame' ) ) {
    my( $f ) = shift;

    $t = sprintf( shift, @_ );
    $t =~ s/\%/\%\%/g; wxLogStatusFrame( $f, $t );
  } else {
    $t = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogStatus( $t );
  }
}

sub LogError {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogError( $t );
}

sub LogFatalError {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogFatalError( $t );
}

sub LogWarning {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogWarning( $t );
}

sub LogMessage {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogMessage( $t );
}

sub LogVerbose {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogVerbose( $t );
}

sub LogSysError {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogSysError( $t ); 
}

sub LogDebug {
  my( $t ) = sprintf( shift, @_ ); $t =~ s/\%/\%\%/g; wxLogDebug( $t ); 
}

my $ts_buf;

sub Wx::Log::SetTimestamp {
    Wx::Log::_SetTimestamp( $_[0], $ts_buf );
}

package Wx::PlThreadEvent;

our %stash : shared;
SetStash( \%stash );

1;

__END__

=head1 NAME

Wx - interface to the wxWidgets cross-platform GUI toolkit

=head1 SYNOPSIS

    use Wx;

    my $app = Wx::SimpleApp->new;
    my $frame = Wx::Frame->new( undef, -1, 'Hello, world!' );

    $frame->Show;
    $app->MainLoop;

=head1 DESCRIPTION

The Wx module is a wrapper for the wxWidgets (formerly known as wxWindows)
GUI toolkit.

This module comes with extensive documentation in HTML format; you
can download it from http://wxperl.sourceforge.net/

=head1 INSTALLATION

Please see F<docs/INSTALL.pod> in source package.

=head1 Windows XP look

For standalone (packed using PAR, Perl2Exe, Perl2App, ...)
applications to get Windows XP look, a file named C<App.exe.manifest>
(assuming the program is named C<App.exe>) and containing the text below
must be placed in the same directory as the executable file.

  <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
  <assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
      <assemblyIdentity
          processorArchitecture="x86"
          version="5.1.0.0"
          type="win32"
          name="Controls"
      />
      <description>Super wxPerl Application</description>
      <dependency>
          <dependentAssembly>
              <assemblyIdentity
                  type="win32"
                  name="Microsoft.Windows.Common-Controls"
                  version="6.0.0.0"
                  publicKeyToken="6595b64144ccf1df"
                  language="*"
                  processorArchitecture="x86"
          />
      </dependentAssembly>
      </dependency>
  </assembly>

=head1 AUTHOR

Mattia Barbon <mbarbon@cpan.org>

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

# Local variables: #
# mode: cperl #
# End: #
