use Test::More;
use Test::LeakTrace;

use syntax 'try';

no_leaks_ok {
    eval q[
        {
            package Test::Import1;
            use syntax 'try';
        }
    ];
} "module setup does not generates memory-leaks";


no_leaks_ok {
    eval q[
        my $code = sub {
            try { }
            catch (Mock::AAA $foo) { }
            catch ($oth) { }
            finally { my $y=5; }
        }
    ];
} "compilation phase does not generates memory-leaks";


no_leaks_ok {
    my $res=0;
    try { die bless({}, "Mock::BBB") }
    catch (Mock::AAA $e) { $res=1 }
    catch (Mock::BBB $e) { $res=2 }
    catch (Mock::CCC $e) { $res=3 }
    catch ($others) { $res=4 }
    finally { $res += 100 }

    die "Invalid response: $res" if $res != 102;
} "execution phase does not generates memory-leaks";

done_testing;
