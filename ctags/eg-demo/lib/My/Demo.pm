package My::Demo;

# Package used for demonstration purposes.  Does nothing useful.

use strict;
use warnings;

use base qw(Exporter);

our @EXPORT_OK = qw(demo_this DEMO2);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

use constant {
    DEMO1   => 'one',
    DEMO2   => 'two',
};

sub demo_this {
    return scalar @_;
}

1;
