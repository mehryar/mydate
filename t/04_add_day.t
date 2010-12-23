#!/usr/local/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '..';
use MyDate;
use Data::Dumper;

my ($d,$d1,$d2,$d3);
my $start;
my $expected;
my $increment;
my $start_date;
my $diff;

#--------------------------------------------------
# add days
#--------------------------------------------------
{
    $start     = '2001-01-01';
    $increment = 1;
    $expected  = '2001-01-02';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_day( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment day = $expected");

    $start     = '2001-02-28';
    $increment = 1;
    $expected  = '2001-03-01';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_day( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment day = $expected");

    # leap year
    $start     = '2000-02-28';
    $increment = 1;
    $expected  = '2000-02-29';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_day( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment day = $expected");

    # turn of the year
    $start     = '2000-12-31';
    $increment = 1;
    $expected  = '2001-01-01';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_day( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment day = $expected");

}
