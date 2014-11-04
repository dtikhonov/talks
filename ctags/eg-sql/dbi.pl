# Example of SQL and Perl tags together

use DBI;

sub select_something {
    my $sth = $dbh->prepare(<<SQL)
        SELECT SOMETHING
          FROM CUSTOMERS
         WHERE STATE=?
           AND something or other
SQL
}

my $dbh = DBI->new(...);
select_something($dbh);
