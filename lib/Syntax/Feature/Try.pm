package Syntax::Feature::Try;

use strict;
use warnings;
use Import::Into;
#use Syntax::Feature::Try::Parser;

our $VERSION = '0.001';
our $PARSER = 'Syntax::Feature::Try';

sub install {
    my ($class, %args) = @_;
    my $target = $args{into};

    $PARSER->import::into($target);
}

# TODO move following code to separate package ...::Parser
use Devel::CallParser;
use XSLoader;
use Exporter 'import';

our @EXPORT = our @EXPORT_OK = qw/ try /;

XSLoader::load();

sub try {
    my ($try_code, $catch_code) = @_;
    eval { $try_code->() };
    if ($@) { $catch_code->() };
}

1;

__END__

=pod

=head1 NAME

Syntax::Feature::Try - try/catch/finally syntax

=head1 SYNOPSIS

    use syntax 'try';

    try {
        # block
    }
    catch (My::Class::Err $e) {
        # handle error type My::Class::Err 
    }
    catch ($e) {
        # handle other exceptions
    }
    finally {
        # cleanup block
    }

=head1 DESCRIPTION

This module implements syntax for try/catch/finally statement.

=head1 SEE ALSO

L<TryCatch>, L<Try>

=head1 AUTHOR

Tomas Pokorny <tnt at cpan dot org>

=head1 COPYRIGHT AND LICENCE

Copyright 2013 - Tomas Pokorny.

This program is free software;
you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
