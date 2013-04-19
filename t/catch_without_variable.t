use Test::Spec;
require Test::NoWarnings;
use Exception::Class qw/ MockErr::AAA  MockErr::BBB /;

use syntax 'try';

describe "catch without variable" => sub {
    it "is working" => sub {
        sub test_catch {
            my $err = shift;
            try {
                die $err if $err;
            }
            catch (MockErr::AAA) {
                return "A";
            }
            catch (MockErr::BBB) {
                return "B";
            }
            catch {
                return "other";
            }
            return "err";
        }

        is(test_catch(MockErr::AAA->new), 'A');
        is(test_catch(MockErr::BBB->new), 'B');
        is(test_catch("abc"), 'other');
        is(test_catch(undef), 'err');
    };
};

it "has no warnings" => sub {
    Test::NoWarnings::had_no_warnings();
};

runtests;
