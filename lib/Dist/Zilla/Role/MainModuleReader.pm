use strict;
use warnings;
package Dist::Zilla::Role::MainModuleReader;
# ABSTRACT: Something that reads the main module file

use Moose::Role;

with 'Dist::Zilla::Role::PerlModuleReader';

=attr source_file

The name of the file to read from.

This defaults to the main module file of the dist, hence the name of
this Role.

=cut

has 'source_file' => (
    is => 'ro',
    lazy => 1,
    isa => 'Str',
    required => 0,
    builder => '_default_source_file',
);

sub _default_source_file {
    my $self = shift;
    $self->zilla->main_module->name;
}

1;
__END__

=head1 SYNOPSIS

    use Dist::Zilla::Role::MainModuleReader;
    [Example code]

=head1 DESCRIPTION

[Description for C<Dist::Zilla::Role::MainModuleReader>.]

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* [L<Some::Related::Module>]

  [Description of how this module is related]
