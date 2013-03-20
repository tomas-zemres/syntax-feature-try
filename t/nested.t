use Test::Spec;
use Test::Exception;

use syntax 'try';

describe "nested try/catch" => sub {
    it "is working" => sub {
        my @log;
        lives_ok {
            try {
                try {
                    push @log, "inner-try";
                    die bless {}, "AAA";
                }
                catch(AAA $e) {
                    push @log, "inner-catch";
                    die $e;    
                }
            }
            catch (AAA $e) {
                push @log, "outer-catch";
            }
            push @log, "done";
        };

        is_deeply(\@log, [qw/
                inner-try
                inner-catch
                outer-catch
                done
            /]);
    };
};

runtests;
