#!/usr/local/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '..';
use MyDate;
use Data::Dumper;

my ($d,$d1,$d2,$d3);

#--------------------------------------------------
# date comparisons
#--------------------------------------------------
{
    $d1 = MyDate->new('2001-01-01');
    $d2 = MyDate->new('2001-01-02');
    $d3 = MyDate->new('2001-01-03');
    ok ($d2 > $d1,
        '$d2 > $d1');
    ok ($d2 < $d3,
        '$d2 < $d3');
    ok ($d2 == $d2,
        '$d2 == $d2');
}
