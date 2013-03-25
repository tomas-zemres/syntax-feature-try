package Syntax::Feature::Try::Handler;

use strict;
use warnings;
use Scalar::Util qw/ blessed /;

sub new {
    my ($class, $try_block, $catch_list, $finally_block) = @_;

    my $self = {
        try_block => $try_block,
        catch_list => $catch_list,
        finally_block => $finally_block,
    };
    return bless($self, $class);
}

sub DESTROY {
    my ($self) = @_;

    return if not $self->{finally_block};
    $self->{finally_block}->();
}

sub run {
    my ($self) = @_;

    local $@;
    eval { $self->{try_block}->() };
    if ($@) {
        my $exception = $@;
        my $handler = $self->get_exception_handler($exception);

        $handler ? $handler->($exception)
                 : $self->rethrow($exception);
    }
}

sub get_exception_handler {
    my ($self, $exception) = @_;

    foreach my $item (@{ $self->{catch_list} }) {
        my ($handler, @args) = @$item;
        return $handler if $self->exception_match_args($exception, @args);
    }
}

sub exception_match_args {
    my ($self, $exception, $className) = @_;

    if (defined $className) {
        return 0 if not blessed($exception);
        return 0 if not $exception->isa($className);
    }
    return 1;   # without args catch all exceptions
}

sub rethrow {
    my ($self, $exception) = @_;
    die $exception;
}

1;
