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
# $date->subtract_day
#--------------------------------------------------
{
    $start_date = "2001-01-01";
    $expected   = "2000-12-30";

    $d = MyDate->new($start_date);

    $d1 = $d->subtract_day(2);

    is ($d1->as_string, $expected,
        "\$date->subtract_day");

    $d = MyDate->new($start_date);

    $d1 = $d - 2;

    is ($d1->as_string, $expected,
        "\$date - 2");
}

#--------------------------------------------------
# subtracting two dates
#--------------------------------------------------
{
    # two simple dates
    $d1 = MyDate->new("2001-01-01");
    $d2 = MyDate->new("2001-01-02");

    $diff = $d2 - $d1;

    is ($diff->seconds, 24 * 60 * 60,
        "2001-01-02 - 2001-01-01 = 86400 seconds");
    is ($diff->minutes, 24 * 60,
        "2001-01-02 - 2001-01-01 = 1440 minutes");
    is ($diff->hours, 24,
        "2001-01-02 - 2001-01-01 = 24 hours");
    is ($diff->days, 1,
        "2001-01-02 - 2001-01-01 = 1 day");

    # another date
    $d1 = MyDate->new("1972-03-19");
    $d2 = MyDate->new("2007-08-29");

    $diff = $d2 - $d1;

    is ($diff->weeks, 1849,
        "2007-08-29 - 1972-03-19 = 1849 weeks");
    is ($diff->months, 35 * 12 + 4,
        "2007-08-29 - 1972-03-19 = 424 months");
    is ($diff->years, 35,
        "2007-08-29 - 1972-03-19 = 35 years");

    # difference of a second
    $expected = 1;
    $d1 = MyDate->new("2001-01-01 00:00:00");
    $d2 = MyDate->new("2001-01-01 00:00:01");
    $diff = $d2 - $d1;
    is ($diff->seconds, $expected,
        "2001-01-01 00:00:01 - 2001-01-01 00:00:00 = 1 sec");

}
