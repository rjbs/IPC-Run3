#!perl -w

## test whether reading from STDIN is preserved when
## run3 is called in between reads

use Test::More;
use IPC::Run3;
use File::Temp qw(tempfile);
use strict;

# call run3 at different lines (problems might manifest itself 
# on different lines, probably due to different buffering of input)
my @check_at = (5, 10, 50, 100, 200, 500);
plan tests => @check_at * 3;

# create a test file for input containing 1000 lines
my $nlines = 1000;
my @exp_lines;
my ($fh, $file) = tempfile(UNLINK => 1);
for (my $i = 1; $i <= $nlines; $i++)
{
    my $line = "this is line $i";
    push @exp_lines, $line;
    print $fh $line, "\n";
}
close $fh;


my ( $in, $out, $err );

foreach my $n (@check_at)
{
    my $nread = 0;
    my $unexpected;
    open STDIN, "<", $file or die "can't open file $file: $!";
    while (<STDIN>)
    {
	chomp;
	$unexpected = qq[line $nread: expected "$exp_lines[$nread]", got "$_"\n]
	    unless $exp_lines[$nread] eq $_ || $unexpected;
	$nread++;

	if ($nread == $n)
	{
            $in = "checking at line $n";
	    run3 [ $^X, '-e', 'print uc $_ while <>' ], \$in, \$out, \$err;
	    die "command failed" unless $? == 0;
            is($out, uc $in);
	}
    }
    close STDIN;

    is($nread, $nlines, "STDIN was read completely");
    ok(!$unexpected, "STDIN as expected") or diag($unexpected);
}


