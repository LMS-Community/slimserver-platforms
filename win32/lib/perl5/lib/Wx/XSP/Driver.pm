package Wx::XSP::Driver;

use strict;

use File::Basename ();
use File::Path ();

use Wx::XSP::Parser;

sub new {
    my( $class, %args ) = @_;
    my $self = bless \%args, $class;

    return $self;
}

sub process {
    my( $self ) = @_;

    foreach my $typemap ( $self->typemaps ) {
        Wx::XSP::Parser->new( file => $typemap )->parse;
    }

    my $parser = Wx::XSP::Parser->new( file => $self->file );
    $parser->parse;
    $self->_write( $self->_emit( $parser ) );
}

sub _write {
    my( $self, $out ) = @_;

    foreach my $f ( keys %$out ) {
        if( $f eq '-' ) {
            print $$out{$f};
        } else {
            File::Path::mkpath( File::Basename::dirname( $f ) );

            open my $fh, '>', $f or die "open '$f': $!";
            binmode $fh;
            print $fh $$out{$f};
            close $fh or die "close '$f': $!";
        }
    }
}

sub _emit {
    my( $self, $parser ) = @_;
    my $data = $parser->get_data;
    my %out;
    my $out_file = '-';
    my %state = ( current_module => undef );

    foreach my $e ( @$data ) {
        if( $e->isa( 'Wx::XSP::Node::Module' ) ) {
            $state{current_module} = $e;
        }
        if( $e->isa( 'Wx::XSP::Node::File' ) ) {
            $out_file = $e->file;
        }
        $out{$out_file} .= $e->print( \%state );
    }

    return \%out;
}

sub typemaps { @{$_[0]->{typemaps}} }
sub file     { $_[0]->{file} }
sub output   { $_[0]->{output} }

1;
