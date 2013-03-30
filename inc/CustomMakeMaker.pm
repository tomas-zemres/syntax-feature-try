package inc::CustomMakeMaker;

use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

around _build_WriteMakefile_args => sub {
    my ($orig, $self) = @_;

    my $args = $self->$orig();

    foreach my $key (qw/ TRY_PARSER_DEBUG TRY_PARSER_DUMP /) {
        next if not $ENV{$key};
        $args->{DEFINE} //= "";
        $args->{DEFINE} .= " -D$key";
    }
    return $args;
};

__PACKAGE__->meta->make_immutable;
