use Test;
use IPC::Run3;
use strict;

my ( $in, $out, $err ) = @_;

my @tests = (
map {
    my @what = @$_;

    sub {
        my $before_fd = IPC::Run3::_max_fd;

        run3 [$^X, '-e1' ], @what;

        my $after_fd = IPC::Run3::_max_fd;

        ok $after_fd, $before_fd;
    },
} (
    [],
    [ \undef, \$out, \$err ],
),
);

plan tests => 0+@tests;

$_->() for @tests;
