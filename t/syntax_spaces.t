use strict;
use warnings;
use Test::More;

use syntax 'try';

my @out;

try # comment 1
    # comment 2
{
    # comment 3
    push @out, 'try';
    die "test1\n";
}
# comment 4
catch # comment 4
{
    # comment 5;
    push @out, 'catch';
}
#comment 6
push @out, 'after';

is_deeply(\@out, [qw/ try catch after/]);

done_testing;
