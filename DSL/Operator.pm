#!/usr/bin/perl -w

package DSL::Operator;

use strict;
use warnings;
use namespace::sweep;
use Moose;

has 'operator' => (
  is => 'rw',
  required => 1
);

has 'arguments' => (
  is => 'rw',
  required => 1
);

my $debug = 1;
# Comment out next line for debug output
#undef $debug;

sub from_parse {
  my $self=shift;
  my @terms;
  print STDERR "DSL::Operator->from_parse( ".(
     (ref $_[0] eq "ARRAY") ?
        "[ ".join(", ",map { my $that = $_;
                             while (ref $that eq 'ARRAY' and @$that == 1) {$that = $that->[0];}
                             ((ref $that) =~ /^DSL::/) ? $that->prettyprint : $that
                           } @{$_[0]})." ]"
     :  (ref $_[0]) =~ /^DSL::/ ? $_[0]->prettyprint : $_[0]
     )." )\n" if defined($debug);
  @terms=@{$_[0]}; shift;
  print STDERR "~~("  if defined($debug);
  for my $that (@terms) {
    print STDERR " \"".(((ref $that) =~ /^DSL::/) ? $that->prettyprint : $that)."\"" if defined($debug);
    while (ref $that eq 'ARRAY' and @$that == 1) {$that = $that->[0];}
  }
  print STDERR " )~~\n"  if defined($debug);
  if (@terms < 2) {
    return $terms[0];
  }
  if (@terms == 3) {
    return __PACKAGE__->new( operator=>$terms[1], arguments=>[$terms[0], $terms[2] ] );
  }
  my @args = (shift @terms);
  my $op = shift @terms;
  my $oneLastTerm=0;
  while((@terms > 1) && ($terms[1] eq $op)) {
    push @args, shift @terms;
    shift @terms;
    $oneLastTerm=1;
  }
  push @args, shift @terms if $oneLastTerm;
  return (@terms == 0)
		? __PACKAGE__->new( operator=>$op, arguments=>[ @args ] )
		: __PACKAGE__->new( operator=>$op, arguments=>[ @args, __PACKAGE__->from_parse(@terms)] );
  
}

sub prettyprint {
  my $self=shift;
  return join(" " . $self->operator . " ", map { $_->prettyprint } @{$self->arguments});
}

sub do {
  my $self=shift;
  my $value;
  my $op_fun={
    '+' => sub { my $v=shift; $v += shift while (@_); return $v; },
    '-' => sub { my $v=shift; $v -= shift while (@_); return $v; },
    '*' => sub { my $v=shift; $v *= shift while (@_); return $v; },
    '/' => sub { my $v=shift; $v /= shift while (@_); return $v; },
  };
  if (exists $op_fun->{$self->operator}) {
    $value = $op_fun->{$self->operator}->(map { $_->can('do') ? $_->do : $_ } @{$self->arguments} );
    return $value;
  }
  else {
    die sprintf("%s: %s: unknown operator!", $0, $self->operator);
  }
}

__PACKAGE__->meta->make_immutable;

1;
