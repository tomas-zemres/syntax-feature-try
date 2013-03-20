use Test::Spec;
use Syntax::Feature::Try::Handler;

use FindBin qw/ $Bin /;
use lib "$Bin/lib";
use test_tools qw/ compile_ok /;

my $mock_code = q[
    use syntax 'try';

    try {  }
    catch (My::Exception::Class_AAA $my_VAR) {  }
    catch (Class_BBB $e) {  }
    catch ($others) {  }
];

describe "parser" => sub {
    my (@parsed, @catch);

    it "can compile try/catch code" => sub {
        Syntax::Feature::Try::Handler->expects('new')->returns(sub {
                my ($local_class, @args) = @_;

                @parsed = @args;
                return stub(run => sub{});
            });

        compile_ok $mock_code;
    };

    describe "generated output" => sub {
        it "has expected format" => sub {
            is(scalar @parsed, 2, "It returns two arguments");
            is(ref $parsed[0], 'CODE', 'first is reference to code for try-block');
            is(ref $parsed[1], 'ARRAY', 'second is reference to list of catch parts');
        };

        it "contains 3 catch blocks" => sub {
            @catch = @{ $parsed[1] };
            is(scalar @catch, 3);
        };

        it "contains correct data for first catch" => sub {
            my ($code_ref, @args) = @{ $catch[0] };
            is(ref $code_ref, 'CODE');
            is_deeply(\@args, ['My::Exception::Class_AAA']);
        };

        it "contains correct data for second catch" => sub {
            my ($code_ref, @args) = @{ $catch[1] };
            is(ref $code_ref, 'CODE');
            is_deeply(\@args, ['Class_BBB']);
        };

        it "contains correct data for third catch" => sub {
            my ($code_ref, @args) = @{ $catch[2] };
            is(ref $code_ref, 'CODE');
            is_deeply(\@args, []);
        };
    };
};

runtests;
