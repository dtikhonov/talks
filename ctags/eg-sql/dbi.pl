# Example of SQL and Perl tags together

use DBI;

my $dbh = DBI->new(...);

my $sth = $dbh->prepare(<<SQL)
    SELECT SOMETHING
      FROM CUSTOMERS
     WHERE STATE=?
       AND something or other
SQL
