use strict;
use warnings;
use Test::More;
use Test::Exception;

use syntax 'try';

sub test_syntax_error {
    my ($code, $err_pattern) = @_;

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    eval $code;
    like($@, $err_pattern);
}

test_syntax_error q[
    try {
    }
], qr/^syntax error: expected catch after try block at \(eval \d+\) line 5.$/;

test_syntax_error q[
    {
        try { print 1 }
        catch 
    }
], qr/^syntax error: expected block after 'catch' at \(eval \d+\) line 5.$/;

test_syntax_error q[
    sub foo {}
    try &foo
    catch { print 1 }
], qr/^syntax error: expected block after 'try' at \(eval \d+\) line 3.$/;

test_syntax_error q[
    try { print 1 }
    try { print 2 }
    catch { print 3 }
], qr/^syntax error: expected catch after try block at \(eval \d+\) line 3.$/;

test_syntax_error q[
    try catch { print 2 }
], qr/^syntax error: expected block after 'try' at \(eval \d+\) line 2.$/;

test_syntax_error q[
    my $x = try { 1 }
            catch { 2 };
], qr/^syntax error at \(eval \d+\) line 3,/;

test_syntax_error q[
    1;
    catch { 2 }
], qr/^Can't call method "catch" without a package or object reference at \(eval \d+\) line 3.$/;

done_testing;
