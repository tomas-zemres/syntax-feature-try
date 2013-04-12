package Syntax::Feature::Try;

use strict;
use warnings;
use XSLoader;
use Scalar::Util qw/ blessed /;

BEGIN {
    our $VERSION = '0.004';
    XSLoader::load();
}

sub install {
    $^H{+HINTKEY_ENABLED} = 1;
}

sub uninstall {
    $^H{+HINTKEY_ENABLED} = 0;
}

# TODO convert "our" to "my" variables
our $end_of_block;
our $return_values;

sub _statement {
    my ($try_block, $catch_list, $finally_block) = @_;

    local $end_of_block;
    my $return;
    local $@;
    # TODO deduplicate try/catch/finally blocks code
    eval {
        BEGIN { $^H{+HINTKEY_BLOCK} = BLOCK_TRY }
        $return = run_block(\&$try_block);
    };
    my $exception = $@;
    if ($exception and $catch_list) {
        my $handler = _get_exception_handler($exception, $catch_list);
        if ($handler) {
            eval {
                BEGIN { $^H{+HINTKEY_BLOCK} = BLOCK_CATCH }
                $return = run_block(\&$handler, $exception);
            };
            $exception = $@;
        }
    }

    if ($finally_block) {
        {
            BEGIN { $^H{+HINTKEY_BLOCK} = BLOCK_FINALLY }
            $return = run_block(\&$finally_block) || $return;
        }
    }

    if ($exception) {
        _rethrow($exception);
    }

    $return_values = $return;
    return $return;
}

sub _get_exception_handler {
    my ($exception, $catch_list) = @_;

    foreach my $item (@{ $catch_list }) {
        my ($handler, @args) = @$item;
        return $handler if _exception_match_args($exception, @args);
    }
}

sub _exception_match_args {
    my ($exception, $className) = @_;

    if (defined $className) {
        return 0 if not blessed($exception);
        return 0 if not $exception->isa($className);
    }
    return 1;   # without args catch all exceptions
}

sub _rethrow {
    my ($exception) = @_;
    local $SIG{__DIE__} = undef;
    die $exception;
}

sub _get_return_value {
    my $return = $return_values;
    undef $return_values;

    return wantarray ? @$return : $return->[0];
}

1;

__END__

=pod

=head1 NAME

Syntax::Feature::Try - try/catch/finally statement for exception handling

=head1 SYNOPSIS

    use syntax 'try';

    try {
        # run this code and handle errors
    }
    catch (My::Class::Err $e) {
        # handle exception based on class "My::Class::Err"
    }
    catch ($e) {
        # handle other exceptions
    }
    finally {
        # cleanup block
    }

=head1 DESCRIPTION

This module implements syntax for try/catch/finally statement with behaviour
similar to other programming languages (like Java, Python, etc.).

It uses perl ( E<gt>= 5.14 ) experimental parser/lexer API.

=head1 SYNTAX

=head2 initiliazation

To initialize this syntax feature call:

    use syntax 'try';

=head2 try

The I<try block> is executed.
If it throws an error, then first I<catch block> (in order) that can handle
thrown error will be executed. Other I<catch blocks> will be skipped.

If none of I<catch blocks> can handle the error, it is thrown out of
whole statement. If I<try block> does not throw an error,
all I<catch blocks> are skipped.

=head2 catch error class

    catch (My::Error $err) { ... }

This I<catch block> can handle error that is instance of class C<My::Error>
or any of it's subclasses.

Caught error is accessible inside I<catch block>
via declared local variable C<$err>.

=head2 catch all errors

To catch all errors use syntax:

    catch ($e) { ... }

Caught error is accessible inside I<catch block>
via declared local variable C<$e>.

=head2 rethrow error

To rethrow caught error call "die $err".

For example (log any Connection::Error):

    try { ... }
    catch (Connection::Error $err) {
        log_error($err);
        die $err;
    }

=head2 finally

The I<finally block> is executed at the end of statement.
It is always executed (even if try or catch block throw an error).

    my $fh;
    try {
        $fh = IO::File->new("/etc/hosts");
        ...
    }
    finally {
        $fh->close if $fh;
    }

B<WARNING>: If finally block throws an exception,
originaly thrown exception (from try/catch block) is discarded.
You can convert errors inside finally block to warnings:

    try {
        # try block
    }
    finally {
        try {
            # cleanup code
        }
        catch ($e) { warn $e }
    }

=head1 Exception::Class

This module is compatible with Exception::Class

    use Exception::Class (
        'My::Test::Error'
    );
    use syntax 'try';

    try {
        ...
        My::Test::Error->throw('invalid password');
    }
    catch (My::Test::Error $err) {
        # handle error here
    }

=head2 return from subrutine

This module supports also calling "return" inside try/catch/finally blocks
to return values from subrutine.

    sub read_config {
        my $file;
        try {
            $fh = IO::File->new(...);
            return $fh->getline; # it returns value from subrutine "read_config"
        }
        catch ($e) {
            # log error
        }
        finally {
            $fh->close();
        }
    }


=head1 CAVEATS

=head2 @_

C<@_> is not accessible inside try/catch/finally blocks,
because these blocks are internally called in different context.

=head2 next, last, redo

C<next>, C<last> and C<redo> is not working inside try/catch/finally blocks,
because these blocks are internally called in different context.

=head1 BUGS

None bugs known.

=head1 SEE ALSO

L<syntax> - Active syntax extensions

L<Exception::Class> - A module that allows you to declare real exception
classes in Perl

=head2 Other similar packages

L<TryCatch> - first class try catch semantics for Perl

L<Try> - nicer exception handling syntax

=head1 AUTHOR

Tomas Pokorny <tnt at cpan dot org>

=head1 COPYRIGHT AND LICENCE

Copyright 2013 - Tomas Pokorny.

This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
