package Wx::XSP::Node;

=head1 NAME

Wx::XSP::Node - Base class for the parser output.

=cut

use strict;

sub new {
  my $ref = shift;
  my $class = ref $ref || $ref;
  my $this = bless {}, $class;

  $this->init( @_ );

  return $this;
}

=head2 Wx::XSP::Node::print

Return a string to be output in the final XS file.
Every class must override this method.

=cut

package Wx::XSP::Node::Raw;

=head1 Wx::XSP::Node::Raw

Contains data that should be output "as is" in the destination file.

=cut

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{ROWS} = $args{rows};
}

=head2 Wx::XSP::Node::Raw::rows

Returns an array reference holding the rows to be output in the final file.

=cut

sub rows { $_[0]->{ROWS} }
sub print { join( "\n", @{$_[0]->rows} ) . "\n" }

package Wx::XSP::Node::Class;

=head1 Wx::XSP::Node::Class

A class.

=cut

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME} = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
  $this->{METHODS} = $args{methods} || [];
}

=head2 Wx::XSP::Node::Class::cpp_name

Returns the C++ name for the class.

=cut

=head2 Wx::XSP::Node::Class::perl_name

Returns the Perl name for the class.

=head2 Wx::XSP::Node::Class::methods

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub methods { $_[0]->{METHODS} }

sub print {
  my $this = shift;
  my $state = shift;
  my $out = '';
  my $pcname = $this->perl_name;

  if( !defined $state->{current_module} ) {
    die "No current module: remember to add a %module{} directive";
  }
  my $cur_module = $state->{current_module}->to_string;

  $out .= <<EOT;

$cur_module PACKAGE=$pcname

EOT

  foreach my $m ( @{$this->methods} ) {
    $out .= $m->print;
  }

  return $out;
}

package Wx::XSP::Node::Function;

use strict;
use base 'Wx::XSP::Node';

=head1 Wx::XSP::Node::Function

A function; this is also a base class for C<Method>.

=cut

sub init {
  my $this = shift;
  my %args = @_;

  $this->{CPP_NAME} = $args{cpp_name};
  $this->{PERL_NAME} = $args{perl_name} || $args{cpp_name};
  $this->{ARGUMENTS} = $args{arguments} || [];
  $this->{RET_TYPE} = $args{ret_type};
  $this->{CODE} = $args{code};
  $this->{CLEANUP} = $args{cleanup};
  $this->{CLASS} = $args{class};
  if( $this->ret_type ) {
    $this->{TYPEMAPS}{RET_TYPE} =
      Wx::XSP::Typemap::get_typemap_for_type( $this->ret_type );
  }
  foreach my $a ( @{$this->arguments} ) {
    my $t = Wx::XSP::Typemap::get_typemap_for_type( $a->type );
    push @{$this->{TYPEMAPS}{ARGUMENTS}}, $t;
  }
}

=head2 Wx::XSP::Node::Function::cpp_name

=head2 Wx::XSP::Node::Function::perl_name

=head2 Wx::XSP::Node::Function::arguments

=head2 Wx::XSP::Node::Function::ret_type

=head2 Wx::XSP::Node::Function::code

=head2 Wx::XSP::Node::Function::cleanup

=cut

sub cpp_name { $_[0]->{CPP_NAME} }
sub perl_name { $_[0]->{PERL_NAME} }
sub arguments { $_[0]->{ARGUMENTS} }
sub ret_type { $_[0]->{RET_TYPE} }
sub code { $_[0]->{CODE} }
sub cleanup { $_[0]->{CLEANUP} }
sub package_static { ( $_[0]->{STATIC} || '' ) eq 'package_static' }
sub class_static { ( $_[0]->{STATIC} || '' ) eq 'class_static' }

#
# return_type
# class_name::function_name( args = def, ... )
#     type arg
#     type arg
#   PREINIT:
#     aux vars
#   [PP]CODE:
#     RETVAL = new Foo( THIS->method( arg1, *arg2 ) );
#   OUTPUT:
#     RETVAL
#   CLEANUP:
#     /* anything */
sub print {
  my $this = shift;
  my $state = shift;
  my $out = '';
  my $fname = $this->perl_function_name;
  my $args = $this->arguments;
  my $ret_type = $this->ret_type;
  my $ret_typemap = $this->{TYPEMAPS}{RET_TYPE};
  my $need_call_function = 0;
  my( $init, $arg_list, $call_arg_list, $code, $output, $cleanup, $precall ) =
    ( '', '', '', '', '', '', '' );

  if( $args ) {
    my $has_self = $this->is_method ? 1 : 0;
    foreach my $i ( 0 .. $#$args ) {
      my $a = ${$args}[$i];
      my $t = $this->{TYPEMAPS}{ARGUMENTS}[$i];
      my $pc = $t->precall_code( sprintf( 'ST(%d)', $i + $has_self ),
                                 $a->name );

      $need_call_function ||=    defined $t->call_parameter_code( '' )
                              || defined $pc;
      $arg_list .= ', ' . $a->name;
      $arg_list .= ' = ' . $a->default if $a->has_default;
      $init .= '    ' . $t->cpp_type . ' ' . $a->name . "\n";

      my $call_code = $t->call_parameter_code( $a->name );
      $call_arg_list .= ', ' . ( defined( $call_code ) ?
                                            $call_code :
                                            $a->name );
      $precall .= $pc . ";\n" if $pc
    }

    $arg_list = substr( $arg_list, 1 ) . ' ' if length $arg_list;
    $call_arg_list = substr( $call_arg_list, 1 ) . ' '
      if length $call_arg_list;
  }
  # same for return value
  $need_call_function ||= $ret_typemap &&
    ( defined $ret_typemap->call_function_code( '', '' ) ||
      defined $ret_typemap->output_code ||
      defined $ret_typemap->cleanup_code );
  # is C++ name != Perl name?
  $need_call_function ||= $this->cpp_name ne $this->perl_name;
  # package-static function
  $need_call_function ||= $this->package_static;

  my $retstr = $ret_typemap ? $ret_typemap->cpp_type : 'void';

  # special case: constructors with name different from 'new'
  # need to be declared 'static' in XS
  if( $this->isa( 'Wx::XSP::Node::Constructor' ) &&
      $this->perl_name ne $this->cpp_name ) {
    $retstr = "static $retstr";
  }

  if( $need_call_function ) {
    my $has_ret = $ret_typemap && !$ret_typemap->type->is_void;
    my $ccode = $this->_call_code( $call_arg_list );
    if( $has_ret && defined $ret_typemap->call_function_code( '', '' ) ) {
      $ccode = $ret_typemap->call_function_code( $ccode, 'RETVAL' );
    } elsif( $has_ret ) {
      $ccode = "RETVAL = $ccode";
    }

    $code .= "  CODE:\n";
    $code .= '    ' . $precall if $precall;
    $code .= '    ' . $ccode . ";\n";

    if( $has_ret && defined $ret_typemap->output_code ) {
      $code .= '    ' . $ret_typemap->output_code . ";\n";
    }
    $output = "  OUTPUT: RETVAL\n" if $has_ret;

    if( $has_ret && defined $ret_typemap->cleanup_code ) {
      $cleanup .= "  CLEANUP:\n";
      $cleanup .= '    ' . $ret_typemap->cleanup_code . ";\n";
    }
  }

  if( $this->code ) {
    $code = "  CODE:\n    " . join( "\n", @{$this->code} ) . "\n";
    $output = "  OUTPUT: RETVAL\n" if $code =~ m/RETVAL/;
  }
  if( $this->cleanup ) {
    $cleanup ||= "  CLEANUP:\n";
    my $clcode = join( "\n", @{$this->cleanup} );
    $cleanup .= "    $clcode\n";
  }

  if( !$this->is_method && $fname =~ /^(.*)::(\w+)$/ ) {
    my $pcname = $1;
    $fname = $2;
    my $cur_module = $state->{current_module}->to_string;
    $out .= <<EOT;

$cur_module PACKAGE=$pcname

EOT
  }

  $out .= "$retstr\n";
  $out .= "$fname($arg_list)\n";
  $out .= $init;
  $out .= $code;
  $out .= $output;
  $out .= $cleanup;
  $out .= "\n";
}

sub perl_function_name { $_[0]->perl_name }
sub is_method { 0 }

=begin documentation

Wx::XSP::Node::_call_code( argument_string )

Return something like "foo( $argument_string )".

=end documentation

=cut

sub _call_code { return $_[0]->cpp_name . '(' . $_[1] . ')'; }

package Wx::XSP::Node::Method;

use strict;
use base 'Wx::XSP::Node::Function';

sub class { $_[0]->{CLASS} }
sub perl_function_name { $_[0]->class->cpp_name . '::' .
                         $_[0]->perl_name }
sub _call_code {
    my( $self ) = @_;

    if( $self->package_static ) {
        return $_[0]->class->cpp_name . '::' .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    } else {
        return "THIS->" .
               $_[0]->cpp_name . '(' . $_[1] . ')';
    }
}

sub is_method { 1 }

package Wx::XSP::Node::Constructor;

use strict;
use base 'Wx::XSP::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in constructor" if $this->{RET_TYPE};
}

sub ret_type {
  my $this = shift;

  Wx::XSP::Node::Type->new( base      => $this->class->cpp_name,
                            pointer   => 1 );
}

sub perl_function_name {
  my $this = shift;
  my( $pname, $cname, $pclass, $cclass ) = ( $this->perl_name,
                                             $this->cpp_name,
                                             $this->class->perl_name,
                                             $this->class->cpp_name );

  if( $pname ne $cname ) {
    return $cclass . '::' . $pname;
  } else {
    return $cclass . '::' . 'new';
  }
}

sub _call_code { return "new " . $_[0]->class->cpp_name .
                   '(' . $_[1] . ')'; }

package Wx::XSP::Node::Destructor;

use strict;
use base 'Wx::XSP::Node::Method';

sub init {
  my $this = shift;
  $this->SUPER::init( @_ );

  die "Can't specify return value in destructor" if $this->{RET_TYPE};
}

sub perl_function_name { $_[0]->class->cpp_name . '::' . 'DESTROY' }

package Wx::XSP::Node::Argument;

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{TYPE} = $args{type};
  $this->{NAME} = $args{name};
  $this->{DEFAULT} = $args{default};
}

sub print {
  my $this = shift;

  return join( ' ',
               $this->type->print,
               $this->name,
               ( $this->default ?
                 ( '=', $this->default ) : () ) );
}

sub type { $_[0]->{TYPE} }
sub name { $_[0]->{NAME} }
sub default { $_[0]->{DEFAULT} }
sub has_default { defined $_[0]->{DEFAULT} }

package Wx::XSP::Node::Type;

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{BASE} = $args{base};
  $this->{POINTER} = $args{pointer} ? 1 : 0;
  $this->{REFERENCE} = $args{reference} ? 1 : 0;
  $this->{CONST} = $args{const} ? 1 : 0;
}

sub is_const { $_[0]->{CONST} }
sub is_reference { $_[0]->{REFERENCE} }
sub is_pointer { $_[0]->{POINTER} }
sub base_type { $_[0]->{BASE} }

sub equals {
  my( $f, $s ) = @_;

  return $f->is_const == $s->is_const
      && $f->is_reference == $s->is_reference
      && $f->is_pointer == $s->is_pointer
      && $f->base_type eq $s->base_type;
}

sub is_void { return $_[0]->base_type eq 'void' &&
                !$_[0]->is_pointer && !$_[0]->is_reference }

sub print_noconst {
  my $this = shift;

  return join( '',
               $this->base_type,
               ( $this->is_pointer ? ( '*' x $this->is_pointer ) :
                 $this->is_reference ? '&' : '' ) );
}

sub print {
  my $this = shift;

  return join( '',
               ( $this->is_const ? 'const ' : '' ),
               $this->base_type,
               ( $this->is_pointer ? ( '*' x $this->is_pointer ) :
                 $this->is_reference ? '&' : '' ) );
}

package Wx::XSP::Node::Module;

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{MODULE} = $args{module};
}

sub module { $_[0]->{MODULE} }
sub to_string { 'MODULE=' . $_[0]->module }
sub print { "\n" }

package Wx::XSP::Node::File;

use strict;
use base 'Wx::XSP::Node';

sub init {
  my $this = shift;
  my %args = @_;

  $this->{FILE} = $args{file};
}

sub file { $_[0]->{FILE} }
sub print { "\n" }

1;
