use strict;
use warnings;
use Test::More;

use syntax 'try';


sub test1 {
    my @out;

    try {
        push @out, "try-out-before"; 
        try {
            push @out, "try-in";
            die "test-err\n";
            push @out, "after-die";
        }
        catch {
            push @out, "catch-in";
        }
        push @out, "try-out-after";
    }
    catch {
        push @out, "catch-out";
    }
    push @out, "after-all";

    return @out; 
}

is_deeply(
    [ test1 ],
    [ qw/
        try-out-before
        try-in
        catch-in
        try-out-after
        after-all
        / ]
);

done_testing;
