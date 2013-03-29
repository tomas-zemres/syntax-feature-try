package Syntax::Feature::Try;

use strict;
use warnings;
use Import::Into;
use Syntax::Feature::Try::Handler;

our $VERSION = '0.002';
our $PARSER = 'Syntax::Feature::Try';
our $HANDLER = 'Syntax::Feature::Try::Handler';

sub install {
    my ($class, %args) = @_;
    my $target = $args{into};

    $PARSER->import::into($target);
}

# TODO move following code to separate package ...::Parser
use Carp;
use Devel::CallParser;
use XSLoader;
use Exporter 'import';

our @EXPORT = our @EXPORT_OK = qw/ try catch finally /;

XSLoader::load();

sub try {
    $HANDLER->new(@_)->run();
}

sub catch {
    croak "syntax error: try/catch/finally block sequence";
}

sub finally {
    croak "syntax error: finally without try block";
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
whole statement. It I<try block> doe not throw an error,
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

Caught error is acessible inside I<catch block>
via declared local variable C<$e>.

=head2 rethrow error

To rethrow caught error simple call "die $err".
For example (log any Connection::Error):

    try { ... }
    catch (Connection::Error $err) {
        log_error($err);
        die $err;
    }

=head2 finally

The L<finally block> is executed at the end of statement.
It is always executed (even if try or catch block throw an error).

    my $fh;
    try {
        $fh = IO::File->new("/etc/hosts");
        ...
    }
    finally {
        $fh->close;
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

=head1 CAVEATS

=head2 @_

C<@_> is not accessible inside try/catch/finally blocks,
because these blocks are internally called in different context.

=head2 return, wantarray

C<return> and C<wantarray> is not working inside try/catch/finally blocks,
because these blocks are internally called in different context.

=head2 next, last, redo

C<next>, C<last> and C<redo> is not working inside try/catch/finally blocks,
because these blocks are internally called in different context.

=head1 TODO

=over

=item return, wantarray, ...

=back

=head1 BUGS

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
