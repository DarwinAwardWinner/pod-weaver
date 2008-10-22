package Pod::Weaver::Weaver::Abstract;
use Moose;
with 'Pod::Weaver::Role::Weaver';

use Moose::Autobox;

sub weave {
  my ($self) = @_;

  my $pkg_node = $self->weaver->perl->find_first('PPI::Statement::Package');

  Carp::croak "couldn't find package declaration in document" unless $pkg_node;

  my $package = $pkg_node->namespace;

  #unless (_h1(NAME => @pod)) {

  $self->log("couldn't find abstract in filename")
     unless my ($abstract) = $self->weaver->perl->serialize =~ /^\s*#+\s*ABSTRACT:\s*(.+)$/m;

  my $name = $package;
  $name .= " - $abstract" if $abstract;

  $self->weaver->output_pod->push(
    Pod::Elemental::Element::Command->new({
      type     => 'command',
      command  => 'head1',
      content  => 'NAME',
      children => [
        Pod::Elemental::Element::Text->new({
          type    => 'text',
          content => $name,
        }),
      ],
    }),
  );
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
