use strict;
use warnings;
package Dist::Zilla::Role::MainPodReader;
# ABSTRACT: Something that reads the main module's POD

use Moose::Role;
with 'Dist::Zilla::Role::MainModuleReader';

# Override default source file to prefer the pod file with the same
# basename if it exists.
around '_default_source_file' => sub {
    my $orig = shift;
    my $self = shift;
    my $pm = $self->orig();
    (my $pod = $pm) =~  s/\.pm$/\.pod/;
    return -e $pod ? $pod : $pm;
}

sub _get_source_pod {
    my ($self) = shift;
    my $source_content = $self->_get_source_content();

    require PPI::Document;

    my $doc = PPI::Document->new(\$source_content);
    my $pod_elems = $doc->find('PPI::Token::Pod');
    my $pod_content = "";
    if ($pod_elems) {
        # Concatenation should stringify it
        $pod_content .= PPI::Token::Pod->merge(@$pod_elems);
    }

    return $pod_content;
}

1;
__END__

=head1 SYNOPSIS

    use Dist::Zilla::Role::MainPodReader;
    [Example code]

=head1 DESCRIPTION

[Description for C<Dist::Zilla::Role::MainPodReader>.]

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* [L<Some::Related::Module>]

  [Description of how this module is related]
