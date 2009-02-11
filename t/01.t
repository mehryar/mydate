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

#--------------------------------------------------
# add month bug
#--------------------------------------------------
{
    $d1 = MyDate->new('2001-01-01');
    $d2 = MyDate->new('2001-01-02');
    ok ($d1 < $d2,
        '$d1 < $d2 - add_month bug d1 is less than d2');
    $d1 = $d1->add_month;
    ok ($d1 > $d2,
        '$d1 > $d2 - d1 = d1 + 1 month: now d1 is greater than d2');
}

#--------------------------------------------------
# another add month bug
#--------------------------------------------------
{
    $d1 = MyDate->new('2001-09-01');

    $d2 = $d1->add_month(1);
    is ($d2->as_string,'2001-10-01',
        '2001-09-01 + 1 month = 2001-10-01');

    $d2 = $d1->add_month(4);
    is ($d2->as_string,'2002-01-01',
        '2001-09-01 + 4 month = 2002-01-01');

    $d2 = $d1->add_month(11);
    is ($d2->as_string,'2002-08-01',
        '2001-09-01 + 11 month = 2002-08-01');

    $d2 = $d1->add_month(12);
    is ($d2->as_string,'2002-09-01',
        '2001-09-01 + 12 month = 2002-09-01');

    $d2 = $d1->add_month(13);
    is ($d2->as_string,'2002-10-01',
        '2001-09-01 + 13 month = 2002-10-01');

    $d2 = $d1->add_month(15);
    is ($d2->as_string,'2002-12-01',
        '2001-09-01 + 15 month = 2002-12-01');

    $d2 = $d1->add_month(16);
    is ($d2->as_string,'2003-01-01',
        '2001-09-01 + 16 month = 2003-01-01');

    $d2 = $d1->add_month(24);
    is ($d2->as_string,'2003-09-01',
        '2001-09-01 + 24 month = 2003-09-01');
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

#--------------------------------------------------
# $date->subtract_day
#--------------------------------------------------
{
    $start_date = "2001-01-01";
    $expected   = "2000-12-30";
    $d = MyDate->new($start_date);
    $d1 = $d->subtract_day(2);
    is ($d1->as_string,$expected,
        "\$date->substract_day");

    $d = MyDate->new($start_date);
    $d1 = $d - 2;
    is ($d1->as_string,$expected,
        "\$date - 2");
}

#--------------------------------------------------
# subtracting two dates
#--------------------------------------------------
{
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

    $d1 = MyDate->new("1972-03-19");
    $d2 = MyDate->new("2007-08-29");
    $diff = $d2 - $d1;
    is ($diff->weeks,1849,
        "2007-08-29 - 1972-03-19 = 1849 weeks");
    is ($diff->months,35 * 12 + 4,
        "2007-08-29 - 1972-03-19 = 424 months");
    is ($diff->years,35,
        "2007-08-29 - 1972-03-19 = 35 years");

    $expected = 1;
    $d1 = MyDate->new("2001-01-01 00:00:00");
    $d2 = MyDate->new("2001-01-01 00:00:01");
    $diff = $d2 - $d1;
    is ($diff->seconds, $expected,
        "2001-01-01 00:00:01 - 2001-01-01 00:00:00 = 1 sec");

}
