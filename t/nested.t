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
                finally {
                    push @log, "inner-finally";
                }
            }
            catch (AAA $e) {
                push @log, "outer-catch";
            }
            finally {
                push @log, "outer-finally";
            }
            push @log, "done";
        };

        is_deeply(\@log, [qw/
                inner-try
                inner-catch
                inner-finally
                outer-catch
                outer-finally
                done
            /]);
    };
};

runtests;
