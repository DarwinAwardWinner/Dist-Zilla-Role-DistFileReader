use strict;
use warnings;
package Dist::Zilla::Role::PerlModuleReader;
# ABSTRACT: Something that reads the content of a Perl module file

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

    use Dist::Zilla::Role::PerlModuleReader;
    [Example code]

=head1 DESCRIPTION

This adds C<ppi_document_for_source_file> and C<pod_for_source_file>
methods to the DistFileReader Role.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* [L<Some::Related::Module>]

  [Description of how this module is related]
