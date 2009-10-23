use strict;
use warnings;

use Test::More;
use Moose::Autobox 0.10;

use Pod::Elemental;
use Pod::Elemental::Selectors -all;
use Pod::Elemental::Transformer::Pod5;
use Pod::Elemental::Transformer::Nester;

use Pod::Weaver;

my $string   = do { local $/; <DATA> };
my $document = Pod::Elemental->read_string($string);

Pod::Elemental::Transformer::Pod5->new->transform_node($document);
Pod::Elemental::Transformer::Nester->new({
  top_selector => s_command('head1'),
  content_selectors => [
    s_command([ qw(head2 head3 head4 over item back) ]),
    s_flat,
  ],
})->transform_node($document);

my $weaver = Pod::Weaver->new;

use Pod::Weaver::Section::Name;
my $name = Pod::Weaver::Section::Name->new({
  weaver      => $weaver,
  plugin_name => 'Name',
});

$weaver->plugins->push($name);

use Pod::Weaver::Section::Generic;
for my $section (qw(SYNOPSIS DESCRIPTION OVERVIEW ATTRIBUTES METHODS)) {
  my $generic = Pod::Weaver::Section::Generic->new({
    weaver      => $weaver,
    plugin_name => $section,
  });

  $weaver->plugins->push($generic);
}

use Pod::Weaver::Section::Leftovers;
my $leftovers = Pod::Weaver::Section::Leftovers->new({
  weaver      => $weaver,
  plugin_name => 'Leftovers',
});

$weaver->plugins->push($leftovers);

my $woven = $weaver->weave_document({
  document => $document,
});

print $woven->as_debug_string, "\n";

__DATA__
=pod

=head1 DESCRIPTION

This is a simple document meant to be used in testing Pod::Weaver.

It does not do very much.

=head1 BE FOREWARNED

This is not supported:

  much at all

Happy hacking!

=head1 SYNOPSIS

This should probably get moved up front.

=cut
