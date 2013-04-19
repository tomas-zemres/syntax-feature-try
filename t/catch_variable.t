use Test::Spec;
require Test::NoWarnings;

use syntax 'try';

sub test_catch_variable {
    my ($err, $expected_result) = @_;

    my $result;
    try { die $err }
    catch (MyTestErr $obj) { $result = $obj }
    catch ($others) { $result = "others: $others" }

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    is($result, $expected_result);
}

sub mock_err {
    return bless \@_, "MyTestErr";
}

describe "exception variable" => sub {

    describe 'for catch(MyTesterr $obj)' => sub {
        it "is locally accessible in catch block" => sub {
            my $mock_err = mock_err();
            test_catch_variable( $mock_err, $mock_err );
        };
    };

    describe 'for catch($others)' => sub {
        it "is locally accessible in catch block" => sub {
            test_catch_variable( "my err\n", "others: my err\n" );
        };
    };

    it "does not override variable in upper scope" => sub {
        my $e = 'orig-value';
        my @done;

        try {
            is($e, 'orig-value');
            die mock_err('AAA');
        }
        catch (MyTestErr $e) {
            push @done, $e;
        }
        catch ($e) {
            die "this is not called";
        }
        finally {
            is($e, 'orig-value');
        }

        is($e, 'orig-value');

        try {
            is($e, 'orig-value');
            die mock_err('BBB');
        }
        catch (MyTestErr $e) {
            push @done, $e;
        }
        finally {
            is($e, 'orig-value');
        }

        is($e, 'orig-value');
        is_deeply(\@done, [mock_err('AAA'), mock_err('BBB')]);
    };
};

it "has no warnings" => sub {
    Test::NoWarnings::had_no_warnings();
};

runtests;
