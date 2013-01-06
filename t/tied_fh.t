#!perl -w
use strict;
use warnings;
use Test::More;
use IPC::Run3;

my @modules = qw( IO::String IO::Scalar );
plan tests => scalar @modules;

foreach my $module (@modules) {
    TODO: {
        todo_skip "$module doesn't implement the required interface", 1;

        subtest $module => sub {
            plan eval "use $module; 1"
                ? (tests => 3)
                : (skip_all => "$module required");

            my $out = $module->new();
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
        };
    };
}
