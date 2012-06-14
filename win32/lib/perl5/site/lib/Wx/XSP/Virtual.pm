package build::Wx::XSP::Virtual;

use strict;
use warnings;

sub new {
    return bless { virtual_methods => {},
                   virtual_classes => {},
                   skip_virtual_base => {},
                   }, $_[0];
}

sub register_plugin {
    my( $class, $parser ) = @_;
    my $instance = $class->new;

    $parser->add_class_tag_plugin( plugin => $instance, tag => 'NoVirtualBase' );
    $parser->add_class_tag_plugin( plugin => $instance, tag => 'VirtualImplementation' );
    $parser->add_method_tag_plugin( plugin => $instance, tag => 'Virtual' );
    $parser->add_post_process_plugin( plugin => $instance );
}

sub handle_class_tag {
    my( $self, $class, $tag, %args ) = @_;

    if( $tag eq 'NoVirtualBase' ) {
        $self->{skip_virtual_base}{$class->cpp_name} = 1;
    } elsif( $tag eq 'VirtualImplementation' ) {
        my %map = @{$args{any_named_arguments}};

        $self->{virtual_implementation}{$class->cpp_name} =
            { name           => $map{Name}[0][0] || '',
              declaration    => join( "\n", @{$map{Declaration}[0] || []} ),
              implementation => join( "\n", @{$map{Implementation}[0] || []} ),
              };
    }

    1;
}

sub handle_method_tag {
    my( $self, $method, $tag, %args ) = @_;

    if(    $args{any_positional_arguments}
        && $args{any_positional_arguments}[0] eq 'pure' ) {
        $self->{virtual_methods}{$method} = [ $method, 1 ];
    } else {
        $self->{virtual_methods}{$method} = [ $method, 0 ];
    }

    1;
}

my %type_map =
  ( 'bool'             => { convert_return => 'SvTRUE( ret )',
                            default_value  => 'false',
                            type_char      => 'b',
                            },
    'int'              => { convert_return => 'SvIV( ret )',
                            default_value  => '0',
                            type_char      => 'i',
                            },
    'long'             => { convert_return => 'SvIV( ret )',
                            default_value  => '0',
                            type_char      => 'l',
                            },
    'double'           => { convert_return => 'SvNV( ret )',
                            default_value  => '0.0',
                            type_char      => 'd',
                            },
    # TODO merge
    'wxAlignment'      => { convert_return => '(wxAlignment)SvIV( ret )',
                            default_value  => '(wxAlignment)0',
                            type_char      => 'i',
                            },
    # TODOD merge
    'wxGridCellAttr::wxAttrKind' =>
                       => { convert_return => '(wxGridCellAttr::wxAttrKind)SvIV( ret )',
                            default_value  => '(wxGridCellAttr::wxAttrKind)0',
                            type_char      => 'i',
                            },
    'unsigned int'     => { convert_return => 'SvUV( ret )',
                            default_value  => '0',
                            type_char      => 'I',
                            },
    # TODO merge
    'size_t'           => { convert_return => 'SvUV( ret )',
                            default_value  => '0',
                            type_char      => 'I',
                            },
    'wxString'         => { convert_return => 'wxPli_sv_2_wxString( aTHX_ ret )',
                            default_value  => 'wxEmptyString',
                            type_char      => 'P',
                            arguments      => '&%s',
                            },
    # TODO merge
    'const wxString&'  => { convert_return => 'wxPli_sv_2_wxString( aTHX_ ret )',
                            default_value  => 'wxEmptyString',
                            type_char      => 'P',
                            arguments      => '&%s',
                            },
    'wxVariant&'       => { convert_return => 'wxPli_sv_2_variant( aTHX_ ret )',
                            default_value  => 'wxVariant()',
                            type_char      => 'q',
                            arguments      => '&%s, "Wx::Variant"',
                            },
    # TODO merge
    'const wxVariant&' => { convert_return => 'wxPli_sv_2_variant( aTHX_ ret )',
                            default_value  => 'wxVariant()',
                            type_char      => 'q',
                            arguments      => '&%s, "Wx::Variant"',
                            },
    'wxBitmap'        => { convert_return => '*(wxBitmap*)wxPli_sv_2_object( aTHX_ ret, "Wx::Bitmap" )',
                           default_value  => 'wxBitmap()',
                           type_char      => 'O',
                           arguments      => '&%s',
                           },
    # TODO merge
    'const wxBitmap&' => { convert_return => '*(wxBitmap*)wxPli_sv_2_object( aTHX_ ret, "Wx::Bitmap" )',
                           default_value  => 'wxBitmap()',
                           type_char      => 'O',
                           arguments      => '&%s',
                           },
    'const wxHeaderColumn&' =>
                         { convert_return => '*(wxHeaderColumn*)wxPli_sv_2_object( aTHX_ ret, "Wx::HeaderColumn" )',
                           type_char      => 'O',
                           arguments      => '&%s',
                           },
    'wxGrid*' =>         { convert_return => '(wxGrid*)wxPli_sv_2_object( aTHX_ ret, "Wx::Grid" )',
                           type_char      => 'O',
                           arguments      => '&%s',
                           },
    'wxGridCellAttr*' => { convert_return => 'convert_GridCellAttrOut( aTHX_ ret )',
                           type_char      => 'O',
                           arguments      => '&%s',
                           },
    );

sub _virtual_typemap {
    my( $type ) = @_;
    my $tm = $type_map{$type->print};

    die "No virtual typemap for ", $type->print unless $tm;

    return $tm;
}

sub _emit_method_conditions {
    my( $class ) = @_;
    my @res;

    foreach my $method ( @{$class->methods} ) {
        next unless $method->isa( 'ExtUtils::XSpp::Node::Preprocessor' );
        push @res, $method;
    }

    return @res;
}

sub post_process {
    my( $self, $nodes ) = @_;

    my @copy = @$nodes;

    foreach my $node ( @copy ) {
        next unless $node->isa( 'ExtUtils::XSpp::Node::Class' );
        next if $self->{virtual_classes}{$node};
        my( @virtual, $abstract_class, @classes, %redefined );

        @classes = $node;
        # find virtual method in this class and in all base classes
        while( @classes ) {
            my $class = shift @classes;
            next if    $class ne $node
                    && $self->{skip_virtual_base}{$class->cpp_name};

            foreach my $method ( @{$class->methods} ) {
                next unless $method->isa( 'ExtUtils::XSpp::Node::Method' );
                # do not generate virtual handling code for methods that
                # are marked as virtual in a base class and redefined as
                # non-virtual in this class
                unless( $self->{virtual_methods}{$method} ) {
                    $redefined{$method->cpp_name} ||= 1;
                    next;
                }
                next if $redefined{$method->cpp_name};

                push @virtual, $self->{virtual_methods}{$method};
                $abstract_class ||= $virtual[-1][1];
            }

            push @classes, @{$class->base_classes};
        }

        next unless @virtual;

        # TODO wxPerl-specific
        my $cpp_class;
        if( $self->{virtual_implementation}{$node->cpp_name}{name} ) {
            $cpp_class = $self->{virtual_implementation}{$node->cpp_name}{name};
        } else {
            ( $cpp_class = $node->cpp_name ) =~ s/^wx/wxPl/;
        }
        my $perl_class;
        if( $abstract_class ) {
            ( $perl_class = $cpp_class ) =~ s/^wx/Wx::/;
        } else {
            ( $perl_class = $cpp_class ) =~ s/^wxPl/Wx::/;
        }
        my $file = lc "xspp/$cpp_class.h";

        my $include = ExtUtils::XSpp::Node::Raw->new
                          ( rows => [ "#include \"$file\"" ] );
        for( my $i = 0; $i <= $#$nodes; ++$i ) {
            next unless $nodes->[$i] == $node;
            splice @$nodes, $i, 0, $include;
            # TODO a very crude hack that should somehow be
            # encapsulated by XS++: the class definition in the
            # generated .h need to use the preprocessor conditions
            # applied to the various methods, but the conditions are
            # only emitted together with the method definition, which
            # require the header
            #
            # this forces the preprocessor #defines to be emitted just before
            # including the header
            splice @$nodes, $i, 0, _emit_method_conditions( $node );
            last;
        }

        # for abstract class, delete all constructors
        my @constructors = grep $_->isa( 'ExtUtils::XSpp::Node::Constructor' ),
                                @{$node->methods};
        my @cpp_code;
        $node->delete_methods( @constructors );

        push @cpp_code, sprintf <<EOC,
#include "cpp/v_cback.h"

class %s : public %s
{
    %s
    // TODO wxPerl-specific
    WXPLI_DECLARE_V_CBACK();
public:
    SV* GetSelf()
    {
        return m_callback.GetSelf();
    }

EOC
          $cpp_class, $node->cpp_name,
          $self->{virtual_implementation}{$node->cpp_name}{declaration} || '';

        # add the (implicit) default constructor
        unless( @constructors ) {
            push @constructors,
                 ExtUtils::XSpp::Node::Constructor->new
                     ( cpp_name        => $cpp_class,
                       arguments       => [],
                       emit_condition  => $node->condition_expression,
                       );
        }

        my( @new_constructors, @call_base );
        foreach my $constructor ( @constructors ) {
            my $cpp_parms = join ', ', map $_->name, @{$constructor->arguments};
            my $cpp_args = join ', ', map $_->print, @{$constructor->arguments};
            my $comma = @{$constructor->arguments} ? ',' : '';

            push @cpp_code, sprintf <<EOC,
    %s( const char* CLASS %s %s )
        : %s( %s ),
          m_callback( "%s" )
    {
        m_callback.SetSelf( wxPli_make_object( this, CLASS ), true );
    }
EOC
              $cpp_class, $comma, $cpp_args, $node->cpp_name, $cpp_parms, $perl_class;

            my $code = [ "RETVAL = new $cpp_class( CLASS $comma $cpp_parms );" ];

            my $ctor_name = $constructor->perl_name eq $node->cpp_name ? $cpp_class : $constructor->perl_name;
            my $new_ctor = ExtUtils::XSpp::Node::Constructor->new
                               ( cpp_name   => $cpp_class,
                                 perl_name  => $ctor_name,
                                 code       => $code,
                                 arguments  => $constructor->arguments,
                                 postcall   => $constructor->postcall,
                                 cleanup    => $constructor->cleanup,
                                 condition  => $constructor->condition,
                                 );

            push @new_constructors, $new_ctor;
        }

        foreach my $m ( @virtual ) {
            my( $method, $pure ) = @$m;
            my( @cpp_parms, @arg_types );
            foreach my $arg ( @{$method->arguments} ) {
                my $typemap = _virtual_typemap( $arg->type );
                my $format = $typemap->{arguments} || '%s';

                push @cpp_parms, sprintf $format, $arg->name;
                push @arg_types, $typemap->{type_char};
            }

            my @base_parms = map $_->name, @{$method->arguments};
            my( $cpp_parms, $arg_types );
            if( @cpp_parms ) {
                $cpp_parms = join ', ', @cpp_parms;
                $arg_types = '"' . join( '', @arg_types ) . '", ';
            } else {
                $cpp_parms = '';
                $arg_types = 'NULL';
            }

            push @cpp_code, '#if ' . ( $method->condition_expression || 1 );
            push @cpp_code, '    ' . $method->print_declaration;
            my $call_base = $node->cpp_name . '::' . $method->cpp_name .
              '(' . join( ', ', @base_parms ) . ')';
            if( $method->ret_type->is_void ) {
                my $default = $pure ? 'return' : $call_base;
                push @cpp_code, sprintf <<EOT,
    // TODO wxPerl-specific
    {
        dTHX;
        if( wxPliFCback( aTHX_ &m_callback, "%s" ) )
        {
            wxPliCCback( aTHX_ &m_callback, G_SCALAR|G_DISCARD,
                         %s %s );
        }
        else
            %s;
    }
EOT
                  $method->cpp_name, $arg_types, $cpp_parms, $default;
            } else {
                my $ret_type_map = _virtual_typemap( $method->ret_type );
                my $default = $pure ? $ret_type_map->{default_value} : $call_base;
                # pure virtual without default value: abort
                if( !defined $default ) {
                    # TODO better error message
                    $default = 'croak( "Must override" );';
                } else {
                    $default = 'return ' . $default;
                }
                my $convert = $ret_type_map->{convert_return};
                push @cpp_code, sprintf <<EOT,
    // TODO wxPerl-specific
    {
        dTHX;
        if( wxPliFCback( aTHX_ &m_callback, "%s" ) )
        {
            wxAutoSV ret( aTHX_ wxPliCCback( aTHX_ &m_callback, G_SCALAR,
                                             %s %s ) );
            return %s;
        }
        else
            %s;
    }
EOT
                  $method->cpp_name, $arg_types, $cpp_parms, $convert, $default;
            }
            push @cpp_code, '#endif';

            my $callbase_decl = $method->ret_type->print . ' ' .
                                'base_' . $method->cpp_name . '( ' .
                                join( ', ', map $_->print, @{$method->arguments} ) . ')' .
                                ( $method->const ? ' const' : '' );

            if( !$pure ) {
                push @cpp_code, '#if ' . ( $method->condition_expression || 1 );
                push @cpp_code, '    ' . $callbase_decl, '    {';

                if( $method->ret_type->is_void ) {
                    push @cpp_code, '        ' . $call_base . ';';
                } else {
                    push @cpp_code, '        return ' . $call_base . ';';
                }

                push @cpp_code, '    }';
                push @cpp_code, '#endif';

                my $call_base = ExtUtils::XSpp::Node::Method->new
                               ( cpp_name       => 'base_' . $method->cpp_name,
                                 perl_name      => $method->perl_name,
                                 arguments      => $method->arguments,
                                 condition      => $method->condition,
                                 emit_condition => $method->condition_expression,
                                 );

                push @call_base, $call_base;
            }
        }

        push @cpp_code, sprintf <<'EOT',
};
%s

EOT
          $self->{virtual_implementation}{$node->cpp_name}{implementation} || '';

        mkdir 'xspp' unless -d 'xspp';
        open my $h_file, '>', $file or die "open '$file': $!";
        print $h_file join "\n", @cpp_code;
        close $h_file;

        ExtUtils::XSpp::Typemap::add_class_default_typemaps( $cpp_class );
        if( $abstract_class ) {
            my $new_class = ExtUtils::XSpp::Node::Class->new
                                ( cpp_name        => $cpp_class,
                                  perl_name       => $perl_class,
                                  base_classes    => [ $node ],
                                  condition       => $node->condition,
                                  emit_condition  => $node->condition_expression,
                                  methods         => [ @new_constructors,
                                                       @call_base ],
                                  );

            push @$nodes, $new_class;
        } else {
            $node->add_methods( @new_constructors );

            if( @call_base ) {
                # make calls to base_* methods available; needs to be a
                # new class object because the generated methods are only
                # available in the generated C++ class
                #
                # does not specify base classes because the base class
                # list is emitted for the class in $node; at some
                # point XS++ should be fixed to detect and remove the
                # duplicate base class list
                my $new_class = ExtUtils::XSpp::Node::Class->new
                                    ( cpp_name        => $cpp_class,
                                      perl_name       => $perl_class,
                                      condition       => $node->condition,
                                      emit_condition  => $node->condition_expression,
                                      methods         => [ @call_base ],
                                      );

                push @$nodes, $new_class;
            }
        }
    }
}

1;
