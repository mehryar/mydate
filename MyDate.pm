package MyDate;
# $Id: MyDate.pm,v 1.14 2007/01/02 16:50:31 mehryar Exp $
use strict;
use warnings;
use Time::Local;
use Carp;
use vars '$VERSION';
$VERSION = 1.03;

use overload q("")  => \&as_string,
             q(+)   => \&add_day,
             q(-)   => \&subtract,
             q(<=>) => \&compare,
             ;

use constant SEC   => 0;
use constant MIN   => 1;
use constant HOUR  => 2;
use constant DAY   => 3;
use constant MONTH => 4;
use constant YEAR  => 5;
use constant WDAY  => 6;
use constant YDAY  => 7;
use constant ISDST => 8;

our %DAYS_IN_MONTH = (
                      1  => 31,
                      2  => 28,
                      3  => 31,
                      4  => 30,
                      5  => 31,
                      6  => 30,
                      7  => 31,
                      8  => 31,
                      9  => 30,
                      10 => 31,
                      11 => 30,
                      12 => 31
                     );

#--------------------------------------------------
# The weekday names are setup as constants so they can be used when checking
# the "wday" value of a date. e.g.
# if ($date->wday == MyDate::Friday) { then party! };
#--------------------------------------------------
use constant Sunday    => 0;
use constant Monday    => 1;
use constant Tuesday   => 2;
use constant Wednesday => 3;
use constant Thursday  => 4;
use constant Friday    => 5;
use constant Saturday  => 6;

our @DAY_NAMES = qw(Sunday Monday Tuesday Wednesday Thursday Friday Saturday);
our @MONTH_NAMES = qw(January February March April May June
                      July August September October November December);

sub new {
    my ($class,@init) = @_;
    my $self = {};
    bless $self, $class;
    $self->_init(@init);
    return $self;
}

sub _init {
    my ($self,@init) = @_;

    if (@init == 1) {
        my $init_string = shift @init;
        # "2007-01-01"
        if ($init_string =~ /^(\d{4})-(\d{2})-(\d{2})$/) {
            $self->_set_date($1,$2,$3);
        }
        # "2007-01-01 12:00:00" or "2007-01-01 12:00"
        elsif ($init_string =~
               /^(\d{4})-(\d{2})-(\d{2}) (\d\d?):(\d\d)(?::(\d\d))?$/) {
            $self->_set_datetime($1,$2,$3,$4,$5,$6||'00');
        }
        # a time() value
        elsif ($init_string =~ /^\d+$/) {
          $self->{time} = $init_string;
          $self->adjust_date;
        }
    }
    elsif (@init == 3) {
        # 2007,01,01
        $self->_set_date(@init);
    }
    elsif (@init == 6) {
        # 2007,01,01,12,0,0
        $self->_set_datetime(@init);
    }
    else {
        # if no args set the object to the current time.
        $self->{time} = time();
        $self->{datetime} = 1;
        $self->adjust_date;
    }
}

sub clone {
    my ($self) = @_;
    my $class = ref $self;
    my $new = $class->new;
    %$new = %$self;
    return $new;
}

sub _set_date {
    my ($self,$year,$month,$day) = @_;
    my $sec  = 0;
    my $min  = 0;
    my $hour = 0;
    $self->{time} = timelocal($sec,$min,$hour,$day,$month - 1, $year - 1900);
    $self->adjust_date;
}

sub _set_datetime {
    my ($self,$year,$month,$day,$hour,$min,$sec) = @_;
    croak "invalid hour $hour\n" unless $hour >= 0 and $hour <= 24;
    croak "invalid min $min\n"   unless $min  >= 0 and $min  <= 60;
    croak "invalid sec $sec\n"   unless $sec  >= 0 and $sec  <= 60;
    $hour = 0 if $hour == 24;
    $self->{time} = timelocal($sec,$min,$hour,$day,$month - 1, $year - 1900);
    $self->adjust_date;
    $self->{datetime} = 1;
}

# now() is an alias for new()
sub now; # A "forward" declaration.
*now = \&new;

sub today {
    my ($class) = @_;
    my $self = $class->new;
    $self = $class->new( $self->as_date ); # "today" is date only.
    return $self;
}

sub add_sec {
    my ($self,$num_seconds) = @_;
    $num_seconds = 1 if ! defined $num_seconds;

    my $d = $self->clone;
    $d->{time} += $num_seconds;
    $d->adjust_date;
    $d->{datetime} = 1;
    return $d;
}

sub add_min {
    my ($self,$num_minutes) = @_;
    $num_minutes = 1 if ! defined $num_minutes;

    my $d = $self->clone;
    $d->{time} += $num_minutes * 60;
    $d->adjust_date;
    $d->{datetime} = 1;
    return $d;
}

sub add_hour {
    my ($self,$num_hours) = @_;
    $num_hours = 1 if ! defined $num_hours;

    my $d = $self->clone;
    $d->{time} += $num_hours * 60 * 60;
    $d->adjust_date;
    $d->{datetime} = 1;
    return $d;
}

sub add_day {
    my ($self,$num_days) = @_;
    $num_days = 1 if ! defined $num_days;

    my $d = $self->clone;
    $d->{time} += $num_days * 24 * 60 * 60;
    $d->adjust_date;
    return $d;
}

sub subtract {
  my ($self,$arg) = @_;
  if (ref $arg) {
    my $d2 = $arg;
    $self->subtract_date($d2);
  } else {
    my $num_days = $arg;
    $self->add_day(- $num_days);
  }
}

sub subtract_day {
    my ($self,$num_days) = @_;
    $self->add_day(- $num_days);
}

sub subtract_date {
    my ($self,$date) = @_;
    my $class = ref $self;
    my $diff = $self->{time} - $date->{time};
    return MyDate::Diff->new($diff);
}

# delta_days() is an alias for substract_date()
sub delta_days;
*delta_days = \&subtract_date;

sub between {
    my ($self,$d1,$d2) = @_;
    my $class = ref $self;
    $d1 = $class->new($d1);
    $d2 = $class->new($d2);
    return ($self >= $d1 and $self <= $d2);
}

sub add_month {
    my ($self,$num_months) = @_;
    $num_months = 1 if ! defined $num_months;

    my $month = $self->{month} + $num_months;
    my $year  = $self->{year};
    my $day   = $self->{day};

    if ($month > 12) {
        my $increment_year = int($month/12);
        $month %= 12;
        if ($month == 0) {
            $increment_year--;
            $month = 12;
        }
        $year += $increment_year;
    }
    elsif ($month < 1) {
        $month = abs $month;
        my $decrement_year = 1 + int($month / 12);
        $year -= $decrement_year;
        $month = 12 - $month % 12;
    }

    # 2001-01-01 + 1 month = 2001-02-01
    # 2001-01-31 + 1 month = 2001-02-28
    # 2000-01-31 + 1 month = 2000-02-29
    my $days_in_month = $DAYS_IN_MONTH{$month};
    if ($month == 2 and MyDate->is_leap_year($year)) {
        $days_in_month = 29;
    }
    if ($day > $days_in_month) {
        $day = $days_in_month;
    }
    my $d = $self->clone;
    $d->_set_date($year,$month,$day);
    return $d;
}

sub is_leap_year {
    my ($self,$year) = @_;

    my $is_leap_year = 0;
    if ($year % 4 == 0) {
        $is_leap_year = 1;
    }
    if ($year % 100 == 0) {
        if ($year % 400 == 0) {
            $is_leap_year = 1;
        } else {
            $is_leap_year = 0;
        }
    }

    return $is_leap_year;
}

#sub add_year {
#    my ($self,$num_years) = @_;
#    $num_years = 1 if ! defined $num_years;
#
#    my $d = $self->clone;
#    $d->{time} += $num_years * 24 * 60 * 60;
#    $d->adjust_date;
#    return $d;
#}

sub adjust_date {
    my ($self) = @_;
    my @time_elements = localtime($self->{time});
    $self->{year}  = $time_elements[YEAR]  + 1900;
    $self->{month} = $time_elements[MONTH] +    1;
    $self->{day}   = $time_elements[DAY];
    $self->{hour}  = $time_elements[HOUR];
    $self->{min}   = $time_elements[MIN];
    $self->{sec}   = $time_elements[SEC];
    $self->{wday}  = $time_elements[WDAY];
}

sub as_string {
    my ($self) = @_;
    if ($self->{datetime}) {
        return $self->as_datetime;
    } else {
        return $self->as_date;
    }
}

sub as_date {
    my ($self) = @_;
    my $string = sprintf("%04d-%02d-%02d",
                         $self->{year},
                         $self->{month},
                         $self->{day});
    return $string;
}

sub as_datetime {
    my ($self) = @_;
    my $string = $self->as_date;
    $string .= sprintf(" %02d:%02d:%02d",
                       $self->{hour},
                       $self->{min},
                       $self->{sec});
    return $string;
}

sub as_date_calc_date {
    my ($self) = @_;
    return @{$self}{'year','month','day'};
}

sub compare {
    my ($self,$date,$is_reversed) = @_;
    return $self->{time} <=> $date->{time};
}

sub year  { $_[0]->{year}  };
sub month { $_[0]->{month} };
sub day   { $_[0]->{day}   };
sub hour  { $_[0]->{hour}  };
sub min   { $_[0]->{min}   };
sub sec   { $_[0]->{sec}   };
sub wday  { $_[0]->{wday}  };
sub day_name         { $DAY_NAMES[ $_[0]->{wday} ] };
sub day_name_short   { substr( $DAY_NAMES[ $_[0]->{wday} ], 0, 3 ) };
sub month_name       { $MONTH_NAMES[ $_[0]->{month} - 1 ] };
sub month_name_short { substr( $MONTH_NAMES[ $_[0]->{month} - 1 ], 0, 3 ) };

# to_s() is an alias for as_string()
# to_s() is Ruby-esque and as_string() is Java-esque.
sub to_s;
*to_s = \&as_string;

package MyDate::Diff;

sub new {
  my ($class,$seconds) = @_;
  my $self = { seconds => $seconds };
  bless $self, $class;
  return $self;
}

sub seconds {
  return $_[0]->{seconds};
}

sub minutes {
  return int($_[0]->{seconds}/60);
}

sub hours {
  return int($_[0]->{seconds}/60/60);
}

sub days {
  return int($_[0]->{seconds}/60/60/24);
}

sub weeks {
  return int($_[0]->{seconds}/60/60/24/7);
}

sub months {
  return int($_[0]->{seconds}/60/60/24/30.5);
}

sub years {
  return int($_[0]->{seconds}/60/60/24/365);
}

1;

__END__

=head1 NAME

MyDate - An object oriented very simple Date class.

=head1 SYNOPSIS

  use MyDate;


  # simple date arithmetic: what could be simpler than this?

  $d = MyDate->today;
  print "Tomorrow is ", $d + 1;


  $christmas = MyDate->new("2006-12-24"); 
  # or
  $christmas = MyDate->new(2006,12,14);

  $days_to_xmas = 0;
  while ($d++ < $christmas) {
      ++$days_to_xmas;
  }
  print "There are ", $days_to_xmas, " days remaining until Christmas";


=head1 DESCRIPTION

This is a very simple Date class to allow a simple interface to the most
basic type of date calculations. Only a few types of methods are available
for now. The class overloads a few arithmetic operators to allow the
simpler interface to date calculations.
It only expects do to simple date calculations in the same time zone as is
defined by your system or Perl, so don't expect to do any timezone calculations
with this module.

=head2 new()

  $date = MyDate->new;   # sets $date to today
  $date = MyDate->today; # same thing
  $date = MyDate->now;   # sets $date to today and time to now

there are a few convenient ways to initialize a date object to a particular
date:

  $xmas = MyDate->new("2006-12-24"); # sql like date
  $xmas = MyDate->new(2006,12,24);   # Date::Calc like date
  $xmas = MyDate->new($another_date_object); # Date::Calc like date

  $meeting_at = MyDate->new(2006,12,24,7,45,00);
  $meeting_at = MyDate->new($another_date_object . " 07:45:00");

=head2 add_day(), add_hour(), add_min(), add_sec(), add_month()

Adds a day (or hour or min etc) to the date.
Or if you give it the number of days/hours/minutes etc to add.
Does not modify the original date object but returns a new date object
after the performing the calculations.

  $today = MyDate->new("2006-01-30");
  $tomorrow = $today->add_day;

  print "Tomorrow is $tomorrow\n";
  print "but today is still $today";

  # should print something like:
  # Tomorrow is 2006-01-31
  # but today is still 2006-01-30

  $day_after_tomorrow = $today->add_day( 2 );

  $date = $today->add_min;
  print $date;
  # will print "2006-01-31 12:25:21"
  # basically adds 1 min to the current datetime object.

  $date = $today->add_month;
  # will advance your date to the same day next month.
  so $date = MyDate->new("2001-01-01");
  $date->add_month will become "2001-02-01"

  but $date = MyDate->new("2001-01-31")
  $date->add_month will become "2001-02-29"
  it should account correctly for leap years.

=head2 subtract_day()

Subtract day subtracts a day from your date. There is no subtract_hour,
subtract_min etc. Because subtract_day is just an alias to add_day anyway.
You can basically use a negative argument to subtract min,hour,sec etc.

  $yesterday = $today->subtract_day;
  $five_minutes_ago = $today->add_min( -5 );

=head2 + -

+ - are overloaded to use add_day or substract_day.

So you can do things like:

  $date_next_year = $date + 365;

=head2 compare (<, <=, >=, >, <=>)

uses a dates time value to compare two dates.

  my $d1 = MyDate->new("2006-01-01 3:45:00");
  my $d2 = MyDate->new("2006-01-01 3:46:00");
  if ($d2 > $d1) {
     print "d2 is greater than d1\n";
  }

=head2 day_name | day_name_short

  $date = MyDate->new("2001-01-01");
  print "Jan 1st 2001 was a ", $date->day_name;
  prints "Jan 1st 2001 was a Monday";

  $date->day_name_short; returns the short name (first 3 characters).

=head2 as_string, to_s, to_date, to_datetime

The date object overloads stringification to print out the date in
a sql dateformat.

  print $date->as_string; # prints "2006-01-01";
  print "date is $date";  # print "date is 2006-01-01"

to_s is a Ruby-esque alias for the Java-esque as_string.

as_date returns just the date part of a date object.
as_datetime returns the date and time.

=head1 BUGS AND LIMITATIONS

This module is considered experimental at the moment, so even though I don't
know of any bugs in the code, use at your own risk.
I find this module very convenient to use but I've developed this with the
XP practice of E<lt>a href="http://c2.com/xp/YouArentGonnaNeedIt.html"E<gt>YAGNILE<lt>/aE<gt>
  "Always implement things when you actually need them, never when you just foresee that you need them."

$date->add_year is not implemented yet, since I haven't had to use it yet. :-)

=head1 SEE ALSO

t/01.t - the test script to see examples of the interface being used.

=head1 AUTHOR

mehryar@mehryar.com
