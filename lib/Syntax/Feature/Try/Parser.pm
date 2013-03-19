package Syntax::Feature::Try::Parser;

use strict;
use warnings;
#use XSLoader;

use Exporter 'import';

our @EXPORT = our @EXPORT_OK = qw/ try /;

# TODO rename module to Syntax::Feature::Try::Parser
#XSLoader::load('Syntax::Feature::Try::Try');

sub try {
    my ($try_code, $catch_code) = @_;
    # TODO
}

1;
