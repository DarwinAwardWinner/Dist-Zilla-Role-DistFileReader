use strict;
use warnings;
package Dist::Zilla::Role::PerlModuleReader;
# ABSTRACT: Something that reads the content of a Perl module in the dist, safely

use Moose::Role;

with 'Dist::Zilla::Role::DistFileReader';

=method ppi_document_for_source_file

Returns the content of the source file as a PPI document.

=cut

sub ppi_document_for_source_file {
    require PPI::Document;
    my ($self) = shift;
    # We need to go through content_for_source_file in order to
    # initialzie the file-change watcher.
    my $source_content = $self->content_for_source_file();
    return PPI::Document->new(\$source_content);
}

=method pod_for_source_file

Returns the POD contained in the source file as a string.

=cut

sub pod_for_source_file {
    require PPI::Document;
    my ($self) = shift;
    my $doc = $self->ppi_document_for_source_file();
    my $pod_elems = $doc->find('PPI::Token::Pod');
    my $pod_content = "";
    if ($pod_elems) {
        # Concatenation should stringify the result
        $pod_content .= PPI::Token::Pod->merge(@$pod_elems);
    }
    return $pod_content;
}

1;
__END__

=head1 SYNOPSIS

    package Dist::Zilla::Plugin::MyPlugin;
    with 'Dist::Zilla::Role::PerlModuleReader';

    sub do_something_with_module_content {
        my $content = $self->content_for_source_file;
        my $ppi = $self->ppi_document_for_source_file;
        my $pod = $self->pod_for_source_file;
        $self->log("Source file's content is:\n$content");
        $self->log("Source file's POD is:\n$pod");
    }

=head1 DESCRIPTION

This extends the L<Dist::Zilla::Role::DistFileReader> role and adds
some perl-file-specific methods, C<ppi_document_for_source_file> and
C<pod_for_source_file>.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* L<Dist::Zilla::Plugin::ReadmeAnyFromPod>

  ReadmeAnyFromPod uses this role (via the MainPodReader role) to read
  the main module content safely.
