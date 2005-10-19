use Test qw( plan );
use IPC::Run3;
use strict;

my ( $in, $out, $err ) = @_;

my %e = (
    map( { chr $_ => sprintf( "\\0x%02d", $_ ) } (0..255) ),
    "\n" => "\\n",
    "\r" => "\\r",
);

sub ok {
    @_ = map { ( my $s = $_ ) =~ s/([\000-\037])/$e{$1}/ge; $s } @_;
    goto &Test::ok;
}

my @tests = (
sub {
    eval { run3 };
    ok $@;
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print "OUT"' ], \undef, \$out, \$err;
    ok $out, "OUT";
},

sub {
    ok $err, "";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print map uc, <>' ], \"in", \$out, \$err;
    ok $out, "IN";
},

sub {
    ok $err, "";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print STDERR map uc, <>' ], \"in", \$out, \$err;
    ok $out, "";
},

sub {
    ok $err, "IN";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print map uc, <>' ], [qw( in1 in2 )], \$out;
    ok $out, "IN1IN2";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print map length($_)."[$_]", <>' ], \"in1\nin2", \$out;
    ok $out, "4[in1\n]3[in2]";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'binmode STDIN; binmode STDOUT; print map length($_)."[$_]", <>' ],
        \"in1\nin2", \$out,
        { binmode_stdin => 1 };
    ok $out, "4[in1\n]3[in2]";
},

sub {
    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'binmode STDIN; binmode STDOUT; print map length($_)."[$_]", <>' ],
        \"in1\r\nin2", \$out,
        { binmode_stdin => 1, binmode_stdout => 1 };
    ok $out, "5[in1\r\n]3[in2]";
},

sub {
    ( $in, $out, $err ) = ();
    my @in = qw( in1 in2 );
    run3 [$^X, '-e', 'print map uc, <>' ], sub { shift @in }, \$out;
    ok $out, "IN1IN2";
},

sub {
    ( $in, $out, $err ) = ();
    my @in = qw( in1 in2 );
    run3 [$^X, '-e',
        '$|=1; select STDERR; $| = 1; for (<>){print STDOUT uc;print STDERR lc}'
    ], \"in1\nin2\n", \$out,\$out;
    ok $out, "IN1\nin1\nIN2\nin2\n";
},

sub {
    my $fn = "t/test.txt";
    unlink $fn or warn "$! unlinking $fn" if -e $fn;

    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print "OUT"' ], \undef, $fn;
    ok -s $fn, 3;
},

sub {
    my $fn = "t/test.txt";
    open FH, ">$fn" or warn "$! opening $fn";

    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print "OUT"' ], \undef, \*FH;

    close FH;
    ok -s $fn, 3;
},

sub {
    my $fn = "t/test.txt";
    open FH, ">$fn" or warn "$! opening $fn";
    print FH "IN1\IN2\n";
    close FH;

    open FH, "<$fn" or warn "$! opening $fn";

    ( $in, $out, $err ) = ();
    run3 [$^X, '-e', 'print <>' ], \*FH, \$out;

    close FH;
    ok $out, "IN1\IN2\n";
},
);

plan tests => 0+@tests;

$_->() for @tests;
