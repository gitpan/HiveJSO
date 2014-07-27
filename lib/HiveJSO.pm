package HiveJSO;
BEGIN {
  $HiveJSO::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO Perl Implementation
$HiveJSO::VERSION = '0.003';
use Moo;
use JSON::MaybeXS;
use HiveJSO::Error;

has did => (
  is => 'ro',
  required => 1,
);

our @attributes = qw(
  device_id
  software_id
  ok
  timestamp
  timestmap_timezone
  data
  info
  error
  error_code
  device
  sources
);

has [@attributes] => (
  is => 'ro',
  predicate => 1,
);

sub new_via_json {
  my ( $class, $json ) = @_;
  return $class->new(decode_json($json));
}

sub parse {
  my ( $class, $string ) = @_;
  return $class->_parse(0,$string);
}

sub parse_one {
  my ( $class, $string ) = @_;
  return $class->_parse(1,$string);
}

sub parse_seek {
  my ( $class, $string ) = @_;
  my @parsed = $class->parse_one($string);
  my ( $obj, $post );
  if (ref $parsed[0]) {
    $obj = shift @parsed;
    $post = shift @parsed;
  } elsif (scalar @parsed == 1) {
    $post = shift @parsed;
  } else {
    shift @parsed;
    $obj = shift @parsed;
    $post = shift @parsed;
  }
  return ( $obj, $post );
}

sub _parse {
  my ( $class, $one, $string ) = @_;
  my @results;
  if ($string =~ /^([^{]*)({[^}]+})(.*)$/) {
    my ( $pre, $obj, $post ) = ( $1, $2, $3 );
    push @results, $pre if $pre && length($pre);
    my $object;
    eval {
      $object = $class->new_via_json($obj);
    };
    if ($@) {
      $object = HiveJSO::Error->new(
        garbage => $obj,
        error => $@,
      );
    }
    push @results, $object;
    push @results, ( $one ? $post : $class->parse($post) ) if $post && length($post);
  } else {
    push @results, $string;
  }
  return @results;
}

1;

__END__

=pod

=head1 NAME

HiveJSO - HiveJSO Perl Implementation

=head1 VERSION

version 0.003

=head1 SYNOPSIS

  my @results = HiveJSO->parse($streambuffer);

  my ( $obj, $post ) = HiveJSO->parse_seek($streambuffer);

=head1 DESCRIPTION

See L<https://github.com/homehivelab/hive-jso> for now.

=head1 METHODS

=head2 parse

=head2 parse_one

=head2 parse_seek

=head1 SUPPORT

IRC

  Join #hardware on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/homehivelab/p5-hivejso
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/homehivelab/p5-hivejso

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
