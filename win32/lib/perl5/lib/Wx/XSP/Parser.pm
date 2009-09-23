package Wx::XSP::Parser;

use strict;

use IO::Handle;
use Wx::XSP::Grammar;

=head1 NAME

Wx::XSP::Parser - an XS++ parser

=cut

sub _my_open {
  my $file = shift;
  local *IN;

  open IN, "< $file" or die "open '$file': $!";

  return *IN;
}

=head2 Wx::XSP::Parser::new( file => path )

Create a new XS++ parser.

=cut

sub new {
  my $ref = shift;
  my $class = ref $ref || $ref;
  my $this = bless {}, $class;
  my %args = @_;

  $this->{FILE} = $args{file};
  $this->{PARSER} = Wx::XSP::Grammar->new;

  return $this;
}

=head2 Wx::XSP::Parser::parse

Parse the file data; returns true on success, false otherwise,
on failure C<get_errors> will return the list of errors.

=cut

sub parse {
  my $this = shift;
  my $fh = _my_open( $this->{FILE} );
  my $buf = '';

  my $parser = $this->{PARSER};
  $parser->YYData->{LEX}{FH} = $fh;
  $parser->YYData->{LEX}{BUFFER} = \$buf;

  $this->{DATA} = $parser->YYParse( yylex   => \&Wx::XSP::Grammar::yylex,
                                    yyerror => \&Wx::XSP::Grammar::yyerror,
                                    yydebug => 0,
                                   );
}

=head2 Wx::XSP::Parser::get_data

Returns a list containing the parsed data. Each item of the list is
a subclass of C<Wx::XSP::Node>

=cut

sub get_data {
  my $this = shift;
  die "'parse' must be called before calling 'get_data'"
    unless exists $this->{DATA};

  return $this->{DATA};
}

=head2 Wx::XSP::Parser::get_errors

Returns the parsing errors as an array.

=cut

sub get_errors {
  my $this = shift;

  return @{$this->{ERRORS}};
}

1;
