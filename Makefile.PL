use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'IPC::Run3',
    VERSION_FROM  => 'lib/IPC/Run3.pm',
    EXE_FILES     => [],
    PREREQ_PM => {
    },
);


sub MY::libscan {
    package MY;
    my $self = shift;
    my ( $path ) = @_;
    return '' if /\.sw[a-z]$/;
    return '' unless length $self->SUPER::libscan( $path );
    return $path;
}
