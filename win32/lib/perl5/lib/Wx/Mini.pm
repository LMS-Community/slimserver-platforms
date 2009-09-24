package Wx::Mini; # for RPM

package Wx;

use strict;

our( $VERSION, $XS_VERSION );
our $alien_key = 'msw_2_8_9_uni_mslu_gcc_3_4';

{
    my $VAR1;
    $Wx::dlls = $VAR1 = {
          'base' => 'wxbase28u_gcc_wxperl.dll',
          'core' => 'wxmsw28u_core_gcc_wxperl.dll',
          'richtext' => 'wxmsw28u_richtext_gcc_wxperl.dll',
          'aui' => 'wxmsw28u_aui_gcc_wxperl.dll',
          'stc' => 'wxmsw28u_stc_gcc_wxperl.dll',
          'gl' => 'wxmsw28u_gl_gcc_wxperl.dll',
          'net' => 'wxbase28u_net_gcc_wxperl.dll',
          'html' => 'wxmsw28u_html_gcc_wxperl.dll',
          'xml' => 'wxbase28u_xml_gcc_wxperl.dll',
          'media' => 'wxmsw28u_media_gcc_wxperl.dll',
          'qa' => 'wxmsw28u_qa_gcc_wxperl.dll',
          'xrc' => 'wxmsw28u_xrc_gcc_wxperl.dll',
          'adv' => 'wxmsw28u_adv_gcc_wxperl.dll'
        };
;
}

$VERSION = '0.90'; # bootstrap will catch wrong versions
$XS_VERSION = $VERSION;
$VERSION = eval $VERSION;

#
# XSLoader/DynaLoader wrapper
#
our( $wx_path );

sub wxPL_STATIC();
sub wx_boot($$) {
  local $ENV{PATH} = $wx_path . ';' . $ENV{PATH} if $wx_path;
  if( $_[0] eq 'Wx' || !wxPL_STATIC ) {
    if( $] < 5.006 ) {
      require DynaLoader;
      no strict 'refs';
      push @{"$_[0]::ISA"}, 'DynaLoader';
      $_[0]->bootstrap( $_[1] );
    } else {
      require XSLoader;
      XSLoader::load( $_[0], $_[1] );
    }
  } else {
    no strict 'refs';
    my $t = $_[0]; $t =~ tr/:/_/;
    &{"_boot_$t"}( $_[0], $_[1] );
  }
}

sub _alien_path {
  return if defined $wx_path;
  return unless length 'msw_2_8_9_uni_mslu_gcc_3_4';
  foreach ( @INC ) {
    if( -d "$_/Alien/wxWidgets/msw_2_8_9_uni_mslu_gcc_3_4" ) {
      $wx_path = "$_/Alien/wxWidgets/msw_2_8_9_uni_mslu_gcc_3_4/lib";
      last;
    }
  }
}

_alien_path();

sub _start {
    wx_boot( 'Wx', $XS_VERSION );

    _boot_Constant( 'Wx', $XS_VERSION );
    _boot_GDI( 'Wx', $XS_VERSION );

    Load();
}

1;
