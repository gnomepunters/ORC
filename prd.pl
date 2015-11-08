#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;
use lib '.';
use DSL;
use IO qw/Handle/;

# Enable warnings within the Parse::RecDescent module.
$::RD_ERRORS = 1; # Make sure the parser dies when it encounters an error
$::RD_WARN   = 1; # Enable warnings. This will warn on unused rules &c.
$::RD_HINT   = 1; # Give out hints to help fix problems.
# $::RD_TRACE  = 90; # Trace behaviour to help fix problems.

STDERR->autoflush(1);
STDOUT->autoflush(1);

my $dsl=DSL->new;

my @tests=(
  "a=7;\nb =6\n;c = a + b;\nprint a;\nprint a+b; print c*a; print a+b*c;\n",
  "print 2 * 2;\n",
  "print 2 * 2 + 1;\n",
  "print 2d6 + 2d6;\n",
  "a=7;\nb =6\n;c = a + b;\nprint a+b+c; print a*b*c;\n",
  "print 2 * 2 * 1;\n",
  "print 2*2*1;\n",
  "print 1d6;\n",
  "print d6;\n",
  "print 2d6;\n",
  "print 2d6, 2d6;\n",
  "print 32d24;\n",
  "a=2d6\n;print a;\n",
  "print 2d6 + 2d6 + 2d6;\n",
);

for my $test (0..$#tests) {
  print  "==========\n";
  printf "Test %2d:\n%s\n", 1+$test, $tests[$test];
  print  "----------\n";
  my $result=$dsl->parse($tests[$test]);
  do {print "****-> Cannot parse test " . ($test+1) . "\n";next;} unless (defined($result));
  # print Dumper($result);
  print $result->prettyprint;
  print "<--Output-->\n";
  my $retResult=$result->do;
  print "--Returned result-->  ".$retResult;
}
print "###########\n\n";

exit;

sub quotestring {
  my $s=shift;
  my $r={
    "\n" => '\n',
    "\t" => '\t',
  };
  my $re=join('', keys %$r);
  $s =~ s{([${re}])}{$r->{$1}//$1}ge;
  return $s;
}