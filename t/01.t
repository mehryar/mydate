#!/usr/local/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '..';
use MyDate;
use Data::Dumper;

my ($d,$d1,$d2,$d3);

#--------------------------------------------------
# defining the interface
#--------------------------------------------------
{
    $d = MyDate->new;
    # same as
    $d = MyDate->now;
    isa_ok($d,'MyDate');

    $d = MyDate->new(2001,1,1);
    is ($d->as_string, '2001-01-01',
        'constructor can take a date array (year,month,mday)');

    $d = MyDate->today;
    ok ($d->as_string =~ /20\d\d-\d\d-\d\d/,
        'constructor MyDate->today');

    $d = MyDate->new(time);
    ok ($d->as_string =~ /20\d\d-\d\d-\d\d/,
        'constructor can take a time() value');
}

#--------------------------------------------------
# I want to be able to add a month to a date.
# what does that mean?
# Jan-01-2001 + 1 month = Feb-01-2001
# but what about
# Jan-31-2001 + 1 month ?
# this should be        = Feb-28-2001 or Feb-29-2001 if it was a leap year.
#--------------------------------------------------
my $start;
my $expected;
my $increment;
my $start_date;
my $diff;
{
    $start_date = '2001-01-01';
    $increment  = 1;
    $expected   = '2001-02-01';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");
    is ($d1->as_string, '2001-01-01',
        'd1 remains unaffected');

    $start_date = '2001-12-01';
    $increment  = 1;
    $expected   = '2002-01-01';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-12-01';
    $increment  = 12;
    $expected   = '2002-12-01';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-01-31';
    $increment  = 1;
    $expected   = '2001-02-28';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2000-01-31';
    $increment  = 1;
    $expected   = '2000-02-29';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-01-31';
    $increment  = 13;
    $expected   = '2002-02-28';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-12-31';
    $increment  = 2;
    $expected   = '2002-02-28';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-12-31';
    $expected   = '2002-01-31';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month;
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-01-31';
    $increment  = -1;
    $expected   = '2000-12-31';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-03-31';
    $increment  = -1;
    $expected   = '2001-02-28';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");

    $start_date = '2001-01-31';
    $increment  = -13;
    $expected   = '1999-12-31';
    $d1 = MyDate->new($start_date);
    $d2 = $d1->add_month($increment);
    is ($d2->as_string, $expected,
        "$start_date + $increment month = $expected");
}

#--------------------------------------------------
# simple accessors
#--------------------------------------------------
{
    $d1 = MyDate->new('2001-02-28');
    is ($d1->year, 2001,
        '$d1->year, 2001');
    ok ($d1->month == 2,
        '$d1->month, 2');
    is ($d1->day, 28,
        '$d1->day, 28');
}

{
    $start     = '2001-02-28 00:00:00';
    $increment = 1;
    $expected  = '2001-02-28 00:00:01';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 1;
    $expected  = '2001-02-28 00:00:59';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 3;
    $expected  = '2001-02-28 00:01:01';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 60;
    $expected  = '2001-02-28 00:01:58';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 600;
    $expected  = '2001-02-28 00:10:58';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 6002;
    $expected  = '2001-02-28 01:41:00';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-28 00:00:58';
    $increment = 60002;
    $expected  = '2001-02-28 16:41:00';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-27 00:00:58';
    $increment = 600_002;
    $expected  = '2001-03-05 22:41:00';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");

    $start     = '2001-02-27 00:00:58';
    $increment = 6_000_002;
    $expected  = '2001-05-07 11:41:00';
    $d1 = MyDate->new($start);
    $d2 = $d1->add_sec( $increment );
    is ($d2->as_string, $expected,
        "$start + $increment sec = $expected");
}
