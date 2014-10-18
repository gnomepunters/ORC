#!/usr/bin/perl -w

use strict;
use warnings;

package DSL;

use Moose;
use namespace::autoclean;
use DSL::Parser;
use DSL::Variable;
use DSL::Statement::Assignment;
use DSL::Statement::Print;
use DSL::Expression;

has 'parser' => (
  is => 'ro',
  builder => '_default_parser',
  handles => { parse => 'parse' },
);

sub _default_parser {
  return DSL::Parser->new;
}

sub run {
  my $self=shift;
  my $program=shift;
  return $self->parser->parse($program);
}

__PACKAGE__->meta->make_immutable;

1;