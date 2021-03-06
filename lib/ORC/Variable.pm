#!/usr/bin/perl -w

package ORC::Variable;

use Modern::Perl qw/2012/;
use namespace::sweep;
use Moose;
use overload '""' => sub { $_[0]->prettyprint };

with 'ORC::Role::Serializable';

my $instance_cache={};

has 'name' => (
  is => 'ro',
  required => 1,
);

has 'value' => (
  is => 'rw',
  predicate => 'has_value',
);

sub BUILD {
  my $self=shift;
  $instance_cache->{$self->name}//=$self;
}

sub get {
  if (ref $_[0]) {
    # instance method
    my $self=shift;
    warn "ORC: '" . $self->name . "' is unset\n" unless ($self->has_value);
    return $self->value;
  }
  else {
    # class method
    my $class=shift;
    my $variable_name=shift;
    $instance_cache->{$variable_name} //= __PACKAGE__->new(name => $variable_name);
    return $instance_cache->{$variable_name};
  }
}

sub set {
  my $self=shift;
  my $value=shift;
  $self->value($value);
}

sub prettyprint {
  my $self=shift;
  return $self->name;
}

sub do {
  my $self=shift;
  return ( ref $self->value and $self->value->can('do')) ? $self->value->do : $self->value;
}

__PACKAGE__->meta->make_immutable;

1;
