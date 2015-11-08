#!/usr/bin/perl -w

package DSL::Number;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload '""' => sub { $_[0]->value }, '0+' => sub { $_[0]->value };

has 'value' => (
  is => 'rw',
  required => 1
);

sub prettyprint {
  my $self=shift;
  return $self->value;
}

sub do {
  my $self=shift;
  return $self->value;
}

__PACKAGE__->meta->make_immutable;

1;
