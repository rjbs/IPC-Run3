package IPC::Run3::ProfLogger;

$VERSION = 0.000_1;

=head1 NAME

IPC::Run3::ProfLogger - Write profiling data to a log file

=head1 SYNOPSIS

    use IPC::Run3::ProfLogger;

    my $l = IPC::Run3::ProfLogger->new;  ## write to "run3.out"
    my $l = IPC::Run3::ProfLogger->new( Destination => $fn );

    $l->app_call( \@cmd, $time );

    $l->run_exit( \@cmd1, @times1 );
    $l->run_exit( \@cmd1, @times1 );

    $l->app_exit( $time );

=head1 DESCRIPTION

Used by IPC::Run3 to write a profiling log file.  Does not
generate reports or maintain statistics; its meant to have minimal
overhead.

Its API is compatible with a tiny subset of the other IPC::Run profiling
classes.

=cut

use strict;

sub new {
    my $class = ref $_[0] ? ref shift : shift;
    my $self = bless { @_ }, $class;
    
    $self->{Destination} = "run3.out"
        unless defined $self->{Destination} && length $self->{Destination};

    open PROFILE, ">$self->{Destination}"
        or die "$!: $self->{Destination}\n";
    binmode PROFILE;
    $self->{FH} = *PROFILE{IO};

    $self->{times} = [];
    return $self;
}

sub run_exit {
    my $self = shift;
    my $fh = $self->{FH};
    print( $fh
        join(
            " ",
            (
                map {
                    my $s = $_;
                    $s =~ s/\\/\\\\/g;
                    $s =~ s/ /_/g;
                    $s;
                } @{shift()}
            ),
            join(
                ",",
                @{$self->{times}},
                @_,
            ),
        ),
        "\n"
    );
}

sub app_exit {
    my $self = shift;
    my $fh = $self->{FH};
    print $fh "\\app_exit ", shift, "\n";
}

sub app_call {
    my $self = shift;
    my $fh = $self->{FH};
    my $t = shift;
    print( $fh
        join(
            " ",
            "\\app_call",
            (
                map {
                    my $s = $_;
                    $s =~ s/\\\\/\\/g;
                    $s =~ s/ /\\_/g;
                    $s;
                } @_
            ),
            $t,
        ),
        "\n"
    );
}

=head1 LIMITATIONS

=head1 COPYRIGHT

    Copyright 2003, R. Barrie Slaymaker, Jr., All Rights Reserved

=head1 LICENSE

You may use this module under the terms of the BSD, Artistic, or GPL licenses,
any version.

=head1 AUTHOR

Barrie Slaymaker <barries@slaysys.com>

=cut

1;
