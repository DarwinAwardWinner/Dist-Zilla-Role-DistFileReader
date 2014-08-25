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
    my $pm = $self->$orig();
    (my $pod = $pm) =~  s/\.pm$/\.pod/;
    return -e $pod ? $pod : $pm;
};

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
