#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 1;

my $test1   = 'Local data tests';
my $datadir = 't/data/input';

use lib './lib';
use DataLiberation::Shapado;
my $got = `bin/dataliberation-shapado $datadir`;
my $expected = "5083ebab97cfef6389005135: how-easy-it-is-to-get-data-out-of-http-crimsonfu-shapado-com\n";
is( $got, $expected, $test1 );

#diag( "Testing DataLiberation::Shapado $DataLiberation::Shapado::VERSION" );
diag("$test1");
