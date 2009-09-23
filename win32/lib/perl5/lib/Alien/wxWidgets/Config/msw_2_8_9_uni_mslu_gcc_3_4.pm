package Alien::wxWidgets::Config::msw_2_8_9_uni_mslu_gcc_3_4;

use strict;

our %VALUES;

{
    no strict 'vars';
    %VALUES = %{
$VAR1 = {
          'defines' => '-DHAVE_W32API_H -D__WXMSW__ -D_UNICODE -DwxUSE_UNICODE_MSLU=1 -DwxUSE_GRAPHICS_CONTEXT=1 -DWXUSINGDLL -DNOPCH -DNO_GCC_PRAGMA ',
          'include_path' => '-IC:\\wxbuild\\perllib\\5.10\\unicode\\lib\\Alien\\wxWidgets\\msw_2_8_9_uni_mslu_gcc_3_4\\lib -IC:\\wxbuild\\wxWidgets\\2.8.9\\unicode\\include -IC:\\wxbuild\\wxWidgets\\2.8.9\\unicode\\contrib\\include -IC:\\wxBuild\\Extra\\Includes ',
          'alien_package' => 'Alien::wxWidgets::Config::msw_2_8_9_uni_mslu_gcc_3_4',
          'version' => '2.008009',
          'alien_base' => 'msw_2_8_9_uni_mslu_gcc_3_4',
          'link_libraries' => '-LC:\\wxbuild\\perllib\\5.10\\unicode\\lib\\Alien\\wxWidgets\\msw_2_8_9_uni_mslu_gcc_3_4\\lib -LC:\\wxbuild\\perllib\\5.10\\unicode\\lib\\Alien\\wxWidgets\\msw_2_8_9_uni_mslu_gcc_3_4\\lib -lwxmsw28u_core -lwxbase28u -lunicows ',
          'c_flags' => ' -fvtable-thunks  -O2 -mthreads -Os ',
          '_libraries' => {
                            'base' => {
                                        'link' => '-lwxbase28u',
                                        'dll' => 'wxbase28u_gcc_wxperl.dll',
                                        'lib' => 'libwxbase28u.a'
                                      },
                            'core' => {
                                        'link' => '-lwxmsw28u_core',
                                        'dll' => 'wxmsw28u_core_gcc_wxperl.dll',
                                        'lib' => 'libwxmsw28u_core.a'
                                      },
                            'richtext' => {
                                            'link' => '-lwxmsw28u_richtext',
                                            'dll' => 'wxmsw28u_richtext_gcc_wxperl.dll',
                                            'lib' => 'libwxmsw28u_richtext.a'
                                          },
                            'aui' => {
                                       'link' => '-lwxmsw28u_aui',
                                       'dll' => 'wxmsw28u_aui_gcc_wxperl.dll',
                                       'lib' => 'libwxmsw28u_aui.a'
                                     },
                            'stc' => {
                                       'link' => '-lwxmsw28u_stc',
                                       'dll' => 'wxmsw28u_stc_gcc_wxperl.dll',
                                       'lib' => 'libwxmsw28u_stc.a'
                                     },
                            'gl' => {
                                      'link' => '-lwxmsw28u_gl',
                                      'dll' => 'wxmsw28u_gl_gcc_wxperl.dll',
                                      'lib' => 'libwxmsw28u_gl.a'
                                    },
                            'net' => {
                                       'link' => '-lwxbase28u_net',
                                       'dll' => 'wxbase28u_net_gcc_wxperl.dll',
                                       'lib' => 'libwxbase28u_net.a'
                                     },
                            'html' => {
                                        'link' => '-lwxmsw28u_html',
                                        'dll' => 'wxmsw28u_html_gcc_wxperl.dll',
                                        'lib' => 'libwxmsw28u_html.a'
                                      },
                            'xml' => {
                                       'link' => '-lwxbase28u_xml',
                                       'dll' => 'wxbase28u_xml_gcc_wxperl.dll',
                                       'lib' => 'libwxbase28u_xml.a'
                                     },
                            'media' => {
                                         'link' => '-lwxmsw28u_media',
                                         'dll' => 'wxmsw28u_media_gcc_wxperl.dll',
                                         'lib' => 'libwxmsw28u_media.a'
                                       },
                            'qa' => {
                                      'link' => '-lwxmsw28u_qa',
                                      'dll' => 'wxmsw28u_qa_gcc_wxperl.dll',
                                      'lib' => 'libwxmsw28u_qa.a'
                                    },
                            'xrc' => {
                                       'link' => '-lwxmsw28u_xrc',
                                       'dll' => 'wxmsw28u_xrc_gcc_wxperl.dll',
                                       'lib' => 'libwxmsw28u_xrc.a'
                                     },
                            'adv' => {
                                       'link' => '-lwxmsw28u_adv',
                                       'dll' => 'wxmsw28u_adv_gcc_wxperl.dll',
                                       'lib' => 'libwxmsw28u_adv.a'
                                     }
                          },
          'link_flags' => ' -s ',
          'shared_library_path' => 'C:\\wxbuild\\perllib\\5.10\\unicode\\lib\\Alien\\wxWidgets\\msw_2_8_9_uni_mslu_gcc_3_4\\lib',
          'compiler' => 'g++',
          'linker' => 'g++',
          'config' => {
                        'compiler_version' => '3.4',
                        'compiler_kind' => 'gcc',
                        'mslu' => '1',
                        'toolkit' => 'msw',
                        'unicode' => 1,
                        'debug' => 0,
                        'build' => 'multi'
                      },
          'wx_base_directory' => 'c:\\wxbuild\\wxWidgets\\2.8.9\\unicode',
          'prefix' => 'c:\\wxbuild\\wxWidgets\\2.8.9\\unicode'
        };
    };
}

my $key = substr __PACKAGE__, 1 + rindex __PACKAGE__, ':';

sub values { %VALUES, key => $key }

sub config {
   +{ %{$VALUES{config}},
      package       => __PACKAGE__,
      key           => $key,
      version       => $VALUES{version},
      }
}

1;
