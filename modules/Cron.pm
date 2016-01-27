#!/usr/bin/perl -w

=head1 NAME

Cron. Manage cron files.

=cut

=head1 SYNOPSIS

Usage:

=for example begin

  #create the helper.
  my $obj = Cron->new();

  # add a cron entry
  $obj->add("root", "* * * * * /test.sh");
  
  # remove a matching cron entry. Accepts a /bin/grep pattern.
  $obj->remove("root", "test.sh");

  # check if a cron entry check
  $obj->check("root", "test.sh");

=for example end

=cut

use strict;
use warnings;

package Cron;

sub new {
  my ( $proto, %supplied ) = (@_);
  my $class = ref($proto) || $proto;
  my $self = {};
  bless( $self, $class );
  return $self;
}

sub check {
  my ($self, $user, $entry) = @_;

  my $cmd = "crontab -u $user -l | grep -q '" . $entry ."'";
  if (system($cmd) == 0) {
    return 1;
  } else {
    return 0;
  }
}

sub add {
  my ($self, $user, $entry) = @_;

  return 1 if ($self->check($user, $entry));

  my $cmd = "crontab -u $user -l";
  my $crontab = `$cmd`; 

  my $newcrontab = $crontab . $entry . "\n";
  open(my $cronpipe, "|-", "crontab -u $user -");
  print $cronpipe $newcrontab;
  close($cronpipe);
  return 0 if (${^CHILD_ERROR_NATIVE} != 0);

  return 1;
}

sub remove {
  my ($self, $user, $entry) = @_;

  return 0 if (!$self->check($user, $entry));

  my $cmd = "crontab -u $user -l | grep -v '" . $entry . "'";
  my $newcrontab = `$cmd`; 
  open(my $cronpipe, "|-", "crontab -u $user -");
  print $cronpipe $newcrontab;
  close($cronpipe);
  return 0 if (${^CHILD_ERROR_NATIVE} != 0);

  return 1;
}

1;
