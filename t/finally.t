use Test::Spec;
use Test::Exception;
use Exception::Class 'MyTestErr';

use syntax 'try';

describe "finally" => sub {
    it "is called if try block ends successfully" => sub {
        my $mock = mock();
        $mock->expects('cleanup_code');

        lives_ok {
            try { }
            finally { $mock->cleanup_code; }
        };
    };

    it "is called if exception is not thrown" => sub {
        my $mock = mock();
        $mock->expects('err_handler');
        $mock->expects('cleanup_code');

        lives_ok {
            try { MyTestErr->throw; }
            catch (MyTestErr $e) { $mock->err_handler; }
            finally { $mock->cleanup_code; }
        };
    };

    it "is called even if exception is not caught" => sub {
        my $mock = mock();
        $mock->expects('cleanup_code');

        throws_ok {
            try { MyTestErr->throw; }
            finally { $mock->cleanup_code; }
        } 'MyTestErr';
    };

    it "is called even if different exception is thrown from catch block" => sub {
        my $mock = mock();
        $mock->expects('cleanup_code');

        throws_ok {
            try { die 123 }
            catch ($e) { MyTestErr->throw }
            finally { $mock->cleanup_code; }
        } 'MyTestErr';
    };
};

runtests;
