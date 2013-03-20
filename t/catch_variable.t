use Test::Spec;

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

describe "exception variable" => sub {
    describe 'for catch(MyTesterr $obj)' => sub {
        it "is locally accessible in catch block" => sub {
            my $mock_err = bless {}, "MyTestErr";
            test_catch_variable( $mock_err, $mock_err );
        };
    };

    describe 'for catch($others)' => sub {
        it "is locally accessible in catch block" => sub {
            test_catch_variable( "my err\n", "others: my err\n" );
        };
    };
};

runtests;
