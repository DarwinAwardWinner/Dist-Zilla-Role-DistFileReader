use strict;
use warnings;
package Dist::Zilla::Role::DistFileReader;
# ABSTRACT: Something that reads the content of a dist file, safely

use Moose::Autobox;

use Moose::Role;

with 'Dist::Zilla::Role::Plugin';

=attr source_file

The name of the file to read from. This should be the name of a file
in the dist.

=cut

has source_file => (
    is => 'ro',
    lazy => 1,
    isa => 'Str',
    required => 1,
);

=attr source_update_is_fatal

If true, then any update to the source file after it has been read
will result in an error. Otherwise updates will just trigger a
warning.

Note that this attribute is used by the default implementation of the
C<on_source_file_update> method. If that method is overriden by the
consuming plugin class, then this option will have no effect unless
the new implementation also uses this attribute.

=cut

has source_update_is_fatal => (
    is => 'ro',
    lazy => 1,
    isa => 'Bool',
    default => 1,
);

=attr _last_source_content

This holds the contents of the source file as of the last time this
plugin read it. We use this to detect when the source file is modified.

=cut

has _last_source_content => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

=attr _watching

This is a flag that gets set the first time the source file is read.
It is used to avoid setting multiple watchers on the file.

=cut

has _watching => (
    is => 'rw',
    isa => 'Bool',
    default => '',
);

sub _file_from_filename {
    my ($self, $filename) = @_;
    for my $file ($self->zilla->files->flatten) {
        return $file if $file->name eq $filename;
    }
    die 'no README found (place [ReadmeAnyFromPod] below [Readme] in dist.ini)!';
}

=method watch_for_source_updates

Register this plugin's C<on_source_file_update> method to be called
with the new content whenever the source file's content is updated.

This is called by any method that reads the source file. This method
is idempotent. Only the first call has an effect.

=cut

sub watch_for_source_updates {
    my ($self) = shift;
    if (not $self->_watching)
    {
        my $source_file = $self->_file_from_filename($self->source_file);
        require Dist::Zilla::Role::File::ChangeNotification;
        Dist::Zilla::Role::File::ChangeNotification->meta->apply($source_file);
        my $plugin = $self;
        $source_file->on_changed(sub {
            my ($self, $newcontent) = @_;
            if ($newcontent ne $plugin->_last_source_content) {
                $plugin->on_source_file_update($newcontent);
            }
        });
        $source_file->watch_file;
        $self->_watching(1);
    }
}

=method content_for_source_file

Returns the content of the source file as a string.

=cut

sub content_for_source_file {
    my ($self) = shift;
    my $source_file = $self->_file_from_filename($self->source_file);
    my $source_content = $self->_last_source_content($source_file->content);
    $self->watch_for_source_updates();
    return $source_content;
}

=method on_source_file_update

If the source file is modified after it has been read, then this
method is called with the new content as an argument. The default
implementation will log a warning or an error (depending on the value
of C<source_update_is_fatal>), but you can override it in your
own class to handle the situation as desired.

=cut

sub on_source_file_update {
    my $self = shift;
    my $message = 'Someone tried to munge ' . $self->source_file . ' after we read from it. You need to adjust the load order of your plugins.';
    if ($self->source_update_is_fatal) {
        $self->log_fatal($message);
    }
    else {
        $self->log($message);
    }
}

sub source_encoding {
    my ($self) = shift;
    my $source_file = $self->_file_from_filename($self->source_file);
    return
        $source_file->can('encoding')
            ? $source_file->encoding
            : 'raw';        # Dist::Zilla pre-5.0
}

1;
__END__

=head1 SYNOPSIS

    package Dist::Zilla::Plugin::MyPlugin;
    with 'Dist::Zilla::Role::DistFileReader';

    sub do_something_with_file_content {
        my $content = $self->content_for_source_file;
        $self->log("Source file's content is:\n$content");
    }

=head1 DESCRIPTION

This role provides a number of conveniences for plugins that read the
content of a generated dist file and operate on that content. The most
important feature is that if the generated dist file is modified by a
FileMunger after its content has already been read, this role will (by
default) throw an error. This ensures that a build is only successful
if the plugin operates on the final content of the source file.

Plugins consuming this role will have two configuation options added:
C<source_file> and C<source_update_is_fatal>.

=head2 TESTS

There are no tests for this distribution, because
L<Dist::Zilla::Plugin::ReadmeAnyFromPod> excercises nearly all the
features of this module.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<rct+perlbug@thompsonclan.org>.

=head1 SEE ALSO

=for :list

* L<Dist::Zilla::Plugin::ReadmeAnyFromPod>

  ReadmeAnyFromPod uses this role (via the MainPodReader role) to read
  the main module content safely.
