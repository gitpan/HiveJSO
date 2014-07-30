package HiveJSO;
BEGIN {
  $HiveJSO::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO Perl Implementation
$HiveJSO::VERSION = '0.005';
use Moo;
use JSON::MaybeXS;
use HiveJSO::Error;
use Digest::CRC qw( crc32 );

has did => (
  is => 'ro',
  required => 1,
);

our @attributes = qw(
  device_id
  software
  ok
  timestamp
  timestamp_timezone
  data
  info
  status
  config
  error
  error_code
  device
  device_web
  device_timestamp
  manufacturer
  manufacturer_web
  manufacturer_factory
  manufacturer_country
  supports
  ranges
  units
);

has [@attributes,'checksum'] => (
  is => 'ro',
  predicate => 1,
);

sub new_via_json {
  my ( $class, $json ) = @_;
  return $class->new(decode_json($json));
}

has hivejso => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso {
  my ( $self ) = @_;
  return encode_json($self->hivejso_data);
}

has hivejso_data => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_data {
  my ( $self ) = @_;
  return {
    did => $self->did,
    (map {
      $self->can('has_'.$_)->($self) ? ( $_ => $self->$_ ) : ()
    } @attributes),
  };
}

has checksum_ok => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_checksum_ok {
  my ( $self ) = @_;
  return $self->has_checksum
    ? $self->checksum eq $self->hivejso_checksum
      ? 1
      : 0
    : 1;
}

has hivejso_checksum => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_checksum {
  my ( $self ) = @_;
  my %obj = %{$self->hivejso_data};
  my $crc_string = join(',',map {
    $_, $self->_get_value_checksum($obj{$_})
  } sort { $a cmp $b } grep { $_ ne 'checksum' } keys %obj);
  return crc32($crc_string);
}

sub _get_value_checksum {
  my ( $self, $value ) = @_;
  if (ref $value eq 'ARRAY') {
    return '['.join(',',map {
      $self->_get_value_checksum($_)
    } @{$value}).']';
  }
  return '"'.$value.'"';
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
  if ($string =~ /^([^{]*)({[^}]+})(.*)/) {
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

version 0.005

=head1 SYNOPSIS

  my @results = HiveJSO->parse($string);

  my ( $obj, $post ) = HiveJSO->parse_seek($buffer);
  if ($obj) {
    $buffer = $post; # leave unparsed data in buffer
    do_something($obj); # do something with the HiveJSO
    # now refeed $buffer, could deliver another object
    # as parse_seek always just seeks the first result
    # the rest stays in $post
  } else {
    # no complete object in buffer yet, need more
  }

=head1 DESCRIPTION

See L<https://github.com/homehivelab/hive-jso> for now.

=head1 METHODS

=head2 parse

Gets out all L<HiveJSO> objects from a string. The returned array also
contains, if exist, the text before and after the objects as part of the
array as not blessed scalars.

=head2 parse_one

=head2 parse_seek

=head1 SUPPORT

IRC

  Join #hardware on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/homehivelab/p5-hivejso
  Pull request and additional contributors are welcome

Issue Tracker

  http://github.com/homehivelab/p5-hivejso/issues

=head1 AUTHOR

Torsten Raudssus <torsten@raudss.us>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Torsten Raudssus.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
