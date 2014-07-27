package HiveJSO;
BEGIN {
  $HiveJSO::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO Perl Implementation
$HiveJSO::VERSION = '0.001';
use Moo;
use JSON::MaybeXS;

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
  my @results;
  if ($string =~ /^([^{]*)({[^}]+})(.*)$/) {
    my ( $pre, $obj, $post ) = ( $1, $2, $3 );
    push @results, $pre if $pre && length($pre);
    push @results, $class->new_via_json($obj);
    push @results, $class->parse($post) if $post && length($post);
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

version 0.001

=head1 SYNOPSIS

  my @results = HiveJSO->parse($streambuffer);

=head1 DESCRIPTION

See L<https://github.com/homehivelab/hive-jso> for now.

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
