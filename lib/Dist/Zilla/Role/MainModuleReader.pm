use strict;
use warnings;
package Dist::Zilla::Role::MainModuleReader;
# ABSTRACT: Something that reads the main module file

use Moose::Role;

=attr source_file

The name of the file to read from.

This defaults to the main module file of the dist, hence the name of
this Role.

=cut

has source_file => (
    is => 'ro',
    lazy => 1,
    isa => 'Str',
    builder => '_default_source_file',
);

sub _default_source_file {
    $self->zilla->main_module->name;
}

=attr source_update_is_fatal

If true, then any update to the source file after it has been read
will result in an error. Otherwise updates will just trigger a
warning.

Note that this attribute is used by the default implementation of the
C<on_source_file_update> method. If that method is overriden by the
consuming class, then the new implementation may or may not use this
attribute.

=cut

has source_update_is_fatal => (
    is => 'ro',
    lazy => 1,
    isa => 'Bool',
    default => 1,
);

# Holds the contents of the source file as of the last time we
# generated a readme from it. We use this to detect when the source
# file is modified so we can update the README file again.
has _last_source_content => (
    is => 'rw', isa => 'Str',
    default => '',
);

=method get_source_content

Returns the content of the source file as a string.

The first time this method is called, it also starts watching the
source file for modifications. If the file's content is changed after
it has been read, The on_source_file_update method is called with the
new content.

=cut

sub get_source_content {
    my ($self) = shift;

    my $source_file = $self->file_from_filename($self->source_file);
    # The first time we read the file, we start watching it for
    # changes.
    if (not $source_file->does('Dist::Zilla::Role::File::ChangeNotification'))
    {
        require Dist::Zilla::Role::File::ChangeNotification;
        Dist::Zilla::Role::File::ChangeNotification->meta->apply($source_file);
        my $plugin = $self;
        $source_file->on_changed(sub {
            my ($self, $newcontent) = @_;
            if ($newcontent ne $self->_last_source_content) {
                $plugin->on_source_file_update($newcontent);
            }
        });
        $source_file->watch_file;
    }

    return $self->_last_source_content($source_file->content);
}

=method on_source_file_update

If the main module file is modified after it has been read, then this
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
