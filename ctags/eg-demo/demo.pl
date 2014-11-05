#!/usr/bin/perl

use strict;

use Data::Dumper;
use My::Demo qw(:all);

my $p = demo_this(@ARGV);

print "p: $p; c = ", DEMO2, "\n";

print Dumper($p);
