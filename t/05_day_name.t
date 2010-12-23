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
# $date->day_name (Monday) and $date->day_name_short (Mon)
#--------------------------------------------------
{
    $start_date = "2001-01-01";
    $expected = "Monday";
    $d = MyDate->new($start_date);
    is ($d->day_name, $expected,
        "$start_date is a $expected");
    is ($d->day_name_short, "Mon",
        "$start_date is a Mon");

    $start_date = "2000-02-29";
    $expected = "Tuesday";
    $d = MyDate->new($start_date);
    is ($d->day_name, $expected,
        "$start_date is a $expected");
    is ($d->day_name_short, "Tue",
        "$start_date is a Tue");
}
