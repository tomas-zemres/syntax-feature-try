package inc::CustomMakeMaker;

use Moose;

extends 'Dist::Zilla::Plugin::MakeMaker::Awesome';

around _build_MakeFile_PL_template => sub {
    my ($orig, $self) = @_;
    return $self->$orig . q[
        use Devel::CallParser 'callparser1_h';
        open my $fh, '>', 'callparser1.h' or die "Couldn't write to callparser1.h";
        $fh->print(callparser1_h);
    ];
};

__PACKAGE__->meta->make_immutable;
