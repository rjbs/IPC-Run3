package IPC::Run3::ProfArrayBuffer;

$VERSION = 0.000_1;

=head1 NAME

IPC::Run3::ProfArrayBuffer - Store profile events in RAM in a Perl ARRAY

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

use strict;


sub new {
    my $class = ref $_[0] ? ref shift : shift;

    my $self = bless { @_ }, $class;

    $self->{Events} = [];

    return $self;
}


my @code;

for ( qw( app_call app_exit run_exit ) ) {
    push @code, <<END_TEMPLATE;
#line 1 IPC::Run3::ProfArrayBuffer::$_()
sub $_ {
    push \@{shift->{Events}}, [ $_ => \@_ ];
}
END_TEMPLATE
}

eval join "", @code, 1 or die $@;

=head1 METHODS

=over

=item get_events

Returns a list of all the events.  Each event is an ARRAY reference
like:

   [ "app_call", 1.1, ... ];

=cut

sub get_events {
    my $self = shift;
    @{$self->{Events}};
}

=back

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
