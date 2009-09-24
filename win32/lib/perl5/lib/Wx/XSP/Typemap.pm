package Wx::XSP::Typemap;

=head1 NAME

Wx::XSP::Typemap - map types

=cut

sub new {
  my $ref = shift;
  my $class = ref $ref || $ref;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 Wx::XSP::Typemap::type

Returns the Wx::XSP::Node::Type that is used for this typemap.

=cut

sub type { $_[0]->{TYPE} }

=head2 Wx::XSP::Typemap::cpp_type()

Returns the C++ type to be used for the local variable declaration.

=head2 Wx::XSP::Typemap::input_code( perl_argument_name, cpp_var_name1, ... )

Code to put the contents of the perl_argument (typically ST(x)) into
the C++ variable(s).

=head2 Wx::XSP::Typemap::output_code()

=head2 Wx::XSP::Typemap::cleanup_code()

=head2 Wx::XSP::Typemap::call_parameter_code( parameter_name )

=head2 Wx::XSP::Typemap::call_function_code( function_call_code, return_variable )

=cut

sub init { }

sub cpp_type { die; }
sub input_code { die; }
sub precall_code { undef }
sub output_code { undef }
sub cleanup_code { undef }
sub call_parameter_code { undef }
sub call_function_code { undef }

my @typemaps;

sub add_typemap_for_type {
  my( $type, $typemap ) = @_;

  unshift @typemaps, [ $type, $typemap ];
}

sub get_typemap_for_type {
  my $type = shift;

  foreach my $t ( @typemaps ) {
    return ${$t}[1] if $t->[0]->equals( $type );
  }

  die "No typemap for type ", $type->print;
  if( $type->is_reference ) {
    return Wx::XSP::Typemap::reference->new( type => $type );
  } else {
    return Wx::XSP::Typemap::simple->new( type => $type );
  }
}

package Wx::XSP::Typemap::parsed;

use base 'Wx::XSP::Typemap';

sub _dl { return defined( $_[0] ) && length( $_[0] ) ? $_[0] : undef }

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
  $this->{CPP_TYPE} = $args{cpp_type} || $args{arg1};
  $this->{CALL_FUNCTION_CODE} = _dl( $args{call_function_code} || $args{arg2} );
  $this->{OUTPUT_CODE} = _dl( $args{output_code} || $args{arg3} );
  $this->{CLEANUP_CODE} = _dl( $args{cleanup_code} || $args{arg4} );
  $this->{PRECALL_CODE} = _dl( $args{precall_code} || $args{arg5} );
}

sub cpp_type { $_[0]->{CPP_TYPE} }
sub output_code { $_[0]->{OUTPUT_CODE} }
sub cleanup_code { $_[0]->{CLEANUP_CODE} }
sub call_parameter_code { undef }
sub call_function_code {
  my( $this, $func, $var ) = @_;
  return unless defined $this->{CALL_FUNCTION_CODE};
  return _replace( $this->{CALL_FUNCTION_CODE}, '$1' => $func, '$$' => $var );
  my $code = $this->{CALL_FUNCTION_CODE};

  $code =~ s/\$1/$func/g;
  $code =~ s/\$\$/$var/g;

  $code;
}

sub precall_code {
  my( $this, $pvar, $cvar ) = @_;
  return unless defined $_[0]->{PRECALL_CODE};
  return _replace( $this->{PRECALL_CODE}, '$1' => $pvar, '$2' => $cvar );
}

sub _replace {
  my( $code ) = shift;
  while( @_ ) {
    my( $f, $t ) = ( shift, shift );
    $code =~ s/\Q$f\E/$t/g;
  }
  return $code;
}

package Wx::XSP::Typemap::simple;

use base 'Wx::XSP::Typemap';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
}

sub cpp_type { $_[0]->{TYPE}->print }
sub output_code { undef } # likewise
sub call_parameter_code { undef }
sub call_function_code { undef }

package Wx::XSP::Typemap::reference;

use base 'Wx::XSP::Typemap';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
}

sub cpp_type { $_[0]->{TYPE}->base_type . '*' }
sub output_code { undef }
sub call_parameter_code { "*( $_[1] )" }
sub call_function_code {
  $_[2] . ' = new ' . $_[0]->type->base_type . '( ' . $_[1] . " )";
}

1;
