#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  run.pl
#
#        USAGE:  ./run.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  YOUR NAME (), 
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  21.09.2010 14:51:26
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;
use lib 'lib';
use Algorithm::TSort qw(Graph tsort);
use Data::Dumper;
use Test::More qw(no_plan);

my $buf = "1 2 3\n2 4\n3 4\n5 5\n6 7\n7 6";
my $fh;
open $fh, "<", \$buf;
my ( $g01, $g02, $g03, $g04 );

( $g01 = Graph( SCALAR => $buf ));
( $g02 = Graph( IO => $fh ));
my $adj;
my @adj_true = ( [2,3], [4], [4], [] );
for ( 1,2,3,4 ){
	$adj->{$_} = [ $g01->adj_nodes( $_ ) ];
	is_deeply( $adj->{$_} , $adj_true[ $_ - 1] , "adj_nodes" );
};
( $g03 = Graph( ADJSUB => sub { $adj->($_[0]) } ));

( $g04 = Graph( ADJ => $adj ) );


my @true_result = (
	[ '1 2 3 4', '1 3 2 4'],
	'2 4',
	'3 4',
	'4',
	'circle',
	'circle', );

sub result_str($){
	my @sorted = eval { $_[0]->(); } ;
	return 'circle' if $@;
	return join " ", @sorted;
}

sub test_str{
	my $graph= shift;
	my $node = shift;
	my $true = $true_result[ $node - 1];
	my @true = ref $true ? @$true : $true ;
	my $result = result_str sub {tsort( $g01 , $node )} ;
	ok( 1 == grep $_ eq $result, @true );
}

for my $gr ( $g01, $g02, $g03, $g04 ){
	for ( 1 .. 6 ){
		test_str( $gr, $_ );
	}
}
