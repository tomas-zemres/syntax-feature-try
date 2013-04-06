use Test::Spec;
use Exception::Class qw/
    Err::AAA
    Err::BBB
/;

use FindBin qw/ $Bin /;
use lib "$Bin/lib";
use test_tools qw/ test_syntax_error compile_ok /;

use syntax 'try';

describe '$SIG{__DIE__}' => sub {
    it "does not brake try/catch/finally mechanism" => sub {
        local $SIG{__DIE__} = sub {
            die "X: @_";
        };

        my $finally_called;
        eval {
            try {
                die "mock-error";   # fist call of DIE-handler
            }
            catch ($out_e) {
                like($out_e, qr/^X: mock-error/);
                try {
                    die $out_e;     # second call of DIE-handler
                }
                catch ($in_e) {
                    like($in_e, qr/^X: X: mock-error/);
                    die $in_e;      # third call of DIE-handler
                }
            }
            finally { $finally_called = 1 }
        };
        like($@, qr/^X: X: X: mock-error/,
            'error modified exactly 3-times');
        ok($finally_called);
    };
};

runtests;
