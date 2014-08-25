use strict;
use warnings;
package Dist::Zilla::Role::MainPodReader;
# ABSTRACT: Something that reads the POD of the main module in the dist, safely

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

    package Dist::Zilla::Plugin::MyPlugin;
    with 'Dist::Zilla::Role::MainPodReader';

    sub do_something_with_module_content {
        my $pod = $self->pod_for_source_file;
        $self->log("Source file's POD is:\n$pod");
        if ($self->source_file =~ m/\.pod$/) {
            $self->log("Source file is a .pod file")
        }
    }

=head1 DESCRIPTION

This extends the L<Dist::Zilla::Role::MainModuleReader>. It modifies
the default for C<source_file> such that if a ".pod" file exists with
the same basename as the main module, it will default to that instead.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* L<Dist::Zilla::Plugin::ReadmeAnyFromPod>

  ReadmeAnyFromPod uses this role to read the main module POD safely.
