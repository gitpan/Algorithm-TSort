package Algorithm::TSort;

use 5.008000;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Algorithm::TSort ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	tsort
	Graph	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw( tsort );
	

our $VERSION = '0.02';
{
	package Algorithm::TSort::ADJ;

	sub adj_nodes{
		my $self = shift;
		my $node = shift;
		for ( $self->{$node} ){
			return @$_ if ref ;
		};
		return ();
	};
	sub nodes{
		return keys %{ $_[0] };
	}
	package Algorithm::TSort::ADJSUB;
	sub adj_nodes{
		my $self = shift;
		my $node = shift;
		return $$self->($node);
	};
}
sub Graph($$){
	my $what = shift;
	my $data = shift;
	die "Graph: undefined input" unless defined $what;
	if ( $what eq 'IO' || $what eq 'SCALAR' ){
		my %c;
		my $line;
		my $fh;
		if ( $what eq 'SCALAR' ){
			open $fh, "<", \$data;			
		}
		else {
			$fh = $data;
		};
		local $/= "\n";
		while( defined ( $line = <$fh> ) ){
			chomp $line;
			next unless $line =~m/\S/;
			my ($node , @deps) = split ' ', $line;
			$c{$node} = \@deps;
		}
		return bless \%c, 'Algorithm::TSort::ADJ';
	}
	elsif ( $what eq 'ADJSUB' ){
		return bless \(my $s=$data), 'Algorithm::TSort::ADJSUB';
	}
	elsif ( $what eq 'ADJ' ){
		my %c = %$data;
		return bless \%c, 'Algorithm::TSort::ADJ';
	}
	else {
		require Carp;
		Carp::croak( "Graph: don't know about \$what='$what'" );
	}
}


# Preloaded methods go here.
sub tsort($;@) {
	my $object = shift;
    my @nodes = @_;
    my @sorted;
    my %seen;
    my $req_sub;
	unless( @nodes ){
		if ($object->can( 'nodes' )){
			@nodes = $object->nodes( );
		}
		else {
			require Carp;
			Carp::croak( "tsort: no nodes for sort" );
		}
	}

    $req_sub = sub {
		my $node = shift;
		if ( $seen{$node} ){
			die "Algorithm::TSort - can't tsort cicle detected" if ( $seen{$node}== 1 );
			return;
		};
		$seen{$node} = 1;
		for ( $object->adj_nodes( $node )){
			$req_sub->( $_ );
		};
		$seen{$node} = 2;
		push @sorted, $node;
    };

    for ( @nodes ){
		next if $seen{$_};
		$req_sub->($_);
    }
    return reverse @sorted;
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Algorithm::TSort - Perl extension for topological sort

=head1 SYNOPSIS

  use Algorithm::TSort;

  
  #  $adj = { 1 => [ 2, 3], 2 => [4], 3 => [4]  } ;
  my (@sorted ) = tsort( Graph( ADJ => $adj ). keys %$adj ); 
  say for @sorted; # Or for perl 5.8 use :  print  "$_\n" for @sorted ;

  # -- OR --
	
  # $adj_sub = sub { return unless $$adj->{ $_[0] } ; return @{$adj->{$_[0]}}; };
  my (@sorted) = tsort( Graph( SUB => $adj_sub ), @nodes_for_sort );

  # -- OR --

  # $buf  = 
  #  "1 2 3
  #   2 4
  #   3 4";
  
  my (@sorted) = tsort( Graph ( SCALAR => $buf ));


  # -- OR --
  #

  my (@sorted) = tsort( Graph ( IO => \*STDIN) );
  print "$_\n" for @sorted;

  # -- OR --
  
  # Write your own class for graph with 'adj_nodes' method
  # my $graph = MyGraph->new;
  # # Initialization ...

  my (@sorted ) = tsort( $graph , @nodes_for_sort );


=head1 DESCRIPTION
Topological sort for varios needs and inputs

=head2 EXPORT

Graph, tsort

=head1 SEE ALSO

L<Topological::Sort>, L<Graph>

=head1 AUTHOR

A. G. Grishaev, E<lt>grian@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by A. G. Grishaev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
