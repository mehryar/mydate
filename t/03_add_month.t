#!/usr/local/bin/perl
use strict;
use warnings;
use Test::More qw(no_plan);
use lib '..';
use MyDate;
use Data::Dumper;

my ($d,$d1,$d2,$d3);

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
