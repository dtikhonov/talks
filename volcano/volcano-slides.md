% Quick To The Volcano!
% Dmitri Tikhonov
% PPW 2014

# ...before we all come to our senses!

![](images/quick-volcano.jpg)

# Two Oft-Used Practices

- One is a Best (TM) practice
- One is a common practice
- Both are wrong

# Using Readonly is wrong

- Solution looking for a problem
- Let us count the ways!

# 1: Readonly variables look like l-values

~~~perl
# This looks like a constant:
ABC;
ABC = 1;    # You'll never write this
~~~

Readonly, on the other hand:

~~~perl
if ($ABC) {
    ...
    $ABC = 0;   # Is this readonly?  Scroll up
                # to find out!  PITA.
}
~~~

# 2: Odd way to declare Readonly

~~~perl
Readonly my $RO => 123;
~~~

. . .

~~~perl
# This compiles, too:
my Readonly $RO => 123;
~~~

. . .

~~~perl
# And this:
Readonly my $RO = 123;  # no fat comma
    # quick, what's the value of $RO?
~~~

# 3: It's a run-time thing

- Easy to introduce bugs

~~~perl
Readonly my $LOG_LEVEL =>
    $config->get('log_level');

# ...later in the code:

if ($error_condition) {
    ++$LOG_LEVEL;   # Oops! Your application
                    # just crashed at the
                    # worst moment.
    try_to_recover_somehow();
}
~~~

# 4: No tags support for Readonly

- Exuberant Ctags does not support it
- Perl::Tags does not support it
    - You have to index *all variables* to get Readonly vars.

# Argument against `use constant`

~~~perl
use constant KB => (1 << 10);
~~~

- Constants do not interpolate!  How do you print it?
- It's a constant.  Why do you need to *print* it?

~~~perl
# If you *have* to print it:
print "One kilobyte is still @{[KB]} bytes\n";
~~~

- It may be ugly, but given pros and cons, `constant`
  is much better than `Readonly`.

# A private method in Perl is a bug

- Problem: private methods in Perl can be overridden, thus
  they are not really private.  It is a bug.

# Example: superclass

~~~perl
package Super::Class;
sub new {
    ...
    $self->_init;
}
sub _init {
}
~~~

# Example: subclass

~~~perl
package Sub::Class;
use base qw(Super::Class);
# Unrelated function, not meant to
# override anything:
sub _init {
    do_something_else_now();
}
~~~

# How to solve it

- The bug is in the superclass
- Easy to fix: do not call it as method

~~~perl
sub new {
    ...
    _init($self);   # function call now
}
~~~

- Yes, you have to give up the arrow
- But you gain peace of mind

# `__END__`

- Send hate mail to dmitri@cpan.org
