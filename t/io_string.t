#!perl -w
use strict;
use warnings;
use Test::More;
BEGIN {
    plan eval 'use IO::String; 1'
        ? (tests => 3)
        : (skip_all => 'IO::String required');
}
use IPC::Run3;

my $out = IO::String->new();
run3 [$^X, '-e', 'print "OUT"' ], \undef, $out, $out;
note $out->pos;
my $from_current_pos = do {
    my $str = '';
    while (<$out>) { $str .= $_ }
    $str;
};
is $from_current_pos => '';

$out->pos(0);
my $from_pos_0 = do {
    my $str = '';
    while (<$out>) { $str .= $_ }
    $str;
};
isnt $from_pos_0 => $from_current_pos;
is $from_pos_0 => 'OUT';