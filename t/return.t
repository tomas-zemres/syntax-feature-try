use Test::Spec;

use FindBin qw/ $Bin /;
use lib "$Bin/lib";
use test_tools qw/ test_syntax_error compile_ok /;


describe "keyword return" => sub {
    it "throws syntax error if it is used inside try block" => sub {
        test_syntax_error q[
            use syntax 'try';

            try {
                return 55;
            }
            catch (Mock::Err $e) { }

        ], qr/^syntax error: return inside try\/catch\/finally blocks is not working at \(eval \d+\) line 5[.]?$/;
    };

    it "throws syntax error if it is used inside catch block" => sub {
        test_syntax_error q[
            use syntax 'try';

            try { die bless {}, "Mock::Err" }
            catch (Mock::Err $e) {
                return 66;
            }

        ], qr/^syntax error: return inside try\/catch\/finally blocks is not working at \(eval \d+\) line 6[.]?$/;
    };

    it "throws syntax error if it is used inside finally block" => sub {
        test_syntax_error q[
            use syntax 'try';

            try {
            }
            finally {
                return 77;
            }

        ], qr/^syntax error: return inside try\/catch\/finally blocks is not working at \(eval \d+\) line 7[.]?$/;
    };

    it "can be used outside try/finally blocks" => sub {
        compile_ok q[
            use syntax 'try';

            my $a = sub { return 11 };
            sub t1 { return 111 }
            t1();

            try { }
            finally { }

            my $b = sub { return 22 };
            sub t2 { return 222 }
            t2();
        ];
    };

    it "can be used inside subrutines defined in try/catch/finally blocks" => sub {
        my @result = compile_ok q[
            use syntax 'try';

            my @res;
            try {
                my $t1 = sub {
                    return 6;
                    return 7;
                };
                push @res, $t1->();

                die bless {}, "Mock::Err";
            }
            catch (Mock::Err $e) {
                my $t2 = sub {
                    return 8;
                    return 9;
                };
                push @res, $t2->();
            }
            return @res;
        ];

        is_deeply(\@result, [6,8]);
    };

    it "can be used outside try/catch/finally blocks" => sub {
        compile_ok q[
            use syntax 'try';

            sub test_return {
                my $x = shift;

                return 55 if $x;

                try {
                }
                catch (Mock::Err $e) {
                }

                return 99;
            }
        ];
    };

    it "can be used inside used modules used in try/catch/finally blocks" => sub {
        compile_ok q[
            use syntax 'try';

            try {
                use mock_module;

                die bless {}, "Mock::Err";
            }
            catch (Mock::Err $e) {
                use mock_module;
            }
        ];
    };

    xit "cannot be used inside file required in try/catch/finally blocks" => sub {
        return local $TODO = "Fix this problem";
        test_syntax_error q[
            use syntax 'try';

            try {
                require 'mock_return.pl';
            }
            catch (Mock::Err $e) {}
        ], qr/^syntax error: return inside try\/catch\/finally blocks is not working at \(eval \d+\) line XX[.]?$/;;
    };
};

runtests;
