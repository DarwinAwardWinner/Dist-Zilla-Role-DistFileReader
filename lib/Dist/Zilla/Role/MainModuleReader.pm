use strict;
use warnings;
package Dist::Zilla::Role::MainModuleReader;
# ABSTRACT: Something that reads the content of the main module in the dist, safely

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

    package Dist::Zilla::Plugin::MyPlugin;
    with 'Dist::Zilla::Role::MainModuleReader';

    sub do_something_with_module_content {
        my $content = $self->content_for_source_file;
        my $ppi = $self->ppi_document_for_source_file;
        my $pod = $self->pod_for_source_file;
        $self->log("Source file's content is:\n$content");
        $self->log("Source file's POD is:\n$pod");
    }

=head1 DESCRIPTION

This is identical to the L<Dist::Zilla::Role::PerlModuleReader> role,
except that the C<source_file> attribute is now optional and defaults
to the main module of the dist.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* L<Dist::Zilla::Plugin::ReadmeAnyFromPod>

  ReadmeAnyFromPod uses this role (via the MainPodReader role) to read
  the main module content safely.
