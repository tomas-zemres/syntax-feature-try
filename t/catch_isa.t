use Test::Spec;
use MooseX::Declare;

use syntax 'try';

# mock classes inheritance for tests
class Mock::Animal                          { }
class Mock::Bird    extends Mock::Animal    { }
class Mock::Raptor  extends Mock::Bird      { }
class Mock::Eagle   extends Mock::Raptor    { }

sub test_catch_bird {
    my ($err, $expected_result) = @_;

    my $result;
    try { die $err }
    catch (Mock::Bird $e) { $result=1 }
    catch ($others) { $result=0 }

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    is($result, $expected_result);
}

describe "catch (Mock::Bird ...) {}" => sub {
    it "handles exception of given class" => sub {
        test_catch_bird( Mock::Bird->new(), 1 );
    };

    it "handles also exceptions based on given class" => sub {
        test_catch_bird( Mock::Raptor->new(), 1 );
        test_catch_bird( Mock::Eagle->new(), 1 );
    };

    it "ignores it's super-class(es)" => sub {
        test_catch_bird( Mock::Animal->new(), 0 );
    };

    it "ignores other exceptions classes" => sub {
        test_catch_bird( bless({}, "Mock::ABC"), 0 ); 
        test_catch_bird( bless({}, "Mock::Bird::Two"), 0 ); 
    }; 

    it "skips also any non-object exceptions" => sub {
        test_catch_bird( {}, 0 );
        test_catch_bird( "mock-error", 0 );
        test_catch_bird( "Mock::Bird", 0 );
    };
};

runtests;
