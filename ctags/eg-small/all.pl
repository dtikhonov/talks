package My::Package;
use constant ABC => 123;
sub do_this;
do_this @ARGV;
sub do_this {
    AGAIN: write; shift;
    goto AGAIN if @_;
}
format =
@#####
$_[0]
.
