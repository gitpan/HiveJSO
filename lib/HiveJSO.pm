package HiveJSO;
BEGIN {
  $HiveJSO::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO Perl Implementation
$HiveJSO::VERSION = '0.007';
use Moo;
use JSON::MaybeXS;
use HiveJSO::Error;
use Digest::CRC qw( crc32 );
use Carp qw( croak );

our %short_attributes = qw(
  c    checksum
  d    data
  ma   manufacturer
  maw  manufacturer_web
  maf  manufacturer_factory
  mac  manufacturer_country
  n    units
  o    command
  p    product_id
  pr   product
  prw  product_web
  prt  product_timestamp
  q    supports
  r    ranges
  s    sources
  t    timestamp
  tz   timestamp_timezone
  u    unit_id
  w    software
  x    error_code
  xt   error
);

our @long_attributes = qw(
  ok
  path
);

our @attributes = sort {
  $a cmp $b
} ( @long_attributes, values %short_attributes );

has [grep { $_ ne 'unit_id' } @attributes] => (
  is => 'ro',
  predicate => 1,
);

has unit_id => (
  is => 'ro',
  required => 1,
);

sub new_via_json {
  my ( $class, $json ) = @_;
  my %obj = %{decode_json($json)};
  return $class->new( %obj, original_json => $json );
}

has original_json => (
  is => 'ro',
  predicate => 1,
);

sub BUILDARGS {
  my ( $class, @args ) = @_;
  my %orig;
  if (scalar @args == 1) {
    %orig = %{$args[0]};
  } else {
    %orig = @args;
  }
  my %attr;

  #
  # only accept allowed attributes
  # only accept short or long not mixed
  #
  my ( $short, $long );
  my $short_long_error = __PACKAGE__." you can't mix short HiveJSO attribute names with long HiveJSO attributes";
  for my $k (keys %orig) {
    if (defined $short_attributes{$k}) {
      croak $short_long_error if $long; $short = 1;
      $attr{$short_attributes{$k}} = $orig{$k};
    } elsif (grep {
      $k eq $short_attributes{$_}
    } keys %short_attributes) {
      croak $short_long_error if $short; $long = 1;
      $attr{$k} = $orig{$k};      
    } elsif (grep { $_ eq $k } @long_attributes) {
      $attr{$k} = $orig{$k};
    } else {
      if ($k eq 'original_json') {
        $attr{$k} = $orig{$k}; delete $orig{$k};
      } else {
        croak __PACKAGE__." '".$k."' is not a valid HiveJSO attribute";
      }
    }
  }

  #
  # remove checksum now of input attributes
  #
  my $checksum = delete $orig{c} || delete $orig{checksum};

  #
  # we need at least 2 attributes without checksum (unit_id and one other)
  #
  if (keys %orig < 2) {
    croak __PACKAGE__." we need more attributes for a valid HiveJSO";
  }

  #
  # ok must be 1
  #
  if (defined $attr{ok} && $attr{ok} != 1) {
    croak __PACKAGE__." ok attribute must be set to 1 for a valid HiveJSO";
  }

  #
  # data attribute validation
  #
  if (defined $attr{data}) {
    croak __PACKAGE__." 'data' must be an array" unless ref $attr{data} eq 'ARRAY';
    for my $data_set (@{$attr{data}}) {
      croak __PACKAGE__." values inside the 'data' array must be arrays" unless ref $data_set eq 'ARRAY';
      croak __PACKAGE__." array inside 'data' array needs at least one value" unless scalar @{$data_set};
      croak __PACKAGE__." first value in array inside 'data' array must be positive integer above 0" unless $data_set->[0] > 0;
    }
  }

  #
  # novell check
  #
  if (defined $attr{error_code}) {
    croak __PACKAGE__." error_code must be positive integer above 0" unless $attr{error_code} > 0;
  }

  #
  # checksum check result is just an attribute, doesn't lead to failure
  #
  if ($checksum) {
    my $calced_checksum = $class->calc_checksum(%orig);
    unless($calced_checksum == $checksum) {
      croak __PACKAGE__." invalid HiveJSO checksum, should be '".$calced_checksum."'";
    };
  }
  return { %attr };
}

sub calc_checksum {
  my ( $class, %obj ) = @_;
  my $checksum_string = join(',',map {
    $_, $class->_get_value_checksum($obj{$_})
  } sort { $a cmp $b } grep {
    $_ ne 'checksum' && $_ ne 'c'
  } keys %obj);
  return crc32($checksum_string);
}

sub _get_value_checksum {
  my ( $class, $value ) = @_;
  if (ref $value eq 'ARRAY') {
    return '['.join(',',map {
      $class->_get_value_checksum($_)
    } @{$value}).']';
  }
  return '"'.$value.'"';
}

has hivejso => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso {
  my ( $self ) = @_;
  return encode_json({
    %{$self->hivejso_data},
    checksum => $self->hivejso_checksum,
  });
}

has hivejso_short => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_short {
  my ( $self ) = @_;
  return encode_json({
    %{$self->hivejso_data_short},
    c => $self->hivejso_checksum_short,
  });
}

has hivejso_data => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_data {
  my ( $self ) = @_;
  return {
    unit_id => $self->unit_id,
    (map {
      $self->can('has_'.$_)->($self) ? ( $_ => $self->$_ ) : ()
    } grep {
      $_ ne 'unit_id' && $_ ne 'checksum' && $_ ne 'c'
    } @attributes),
  };
}

has hivejso_data_short => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_data_short {
  my ( $self ) = @_;
  my %short_data = (
    u => $self->unit_id,
    (map {
      $self->can('has_'.$_)->($self) ? ( $_ => $self->$_ ) : ()
    } grep {
      $_ ne 'unit_id' && $_ ne 'checksum' && $_ ne 'c'
    } @attributes),
  );
  for my $k (keys %short_attributes) {
    if ($short_data{$short_attributes{$k}}) {
      $short_data{$k} = delete $short_data{$short_attributes{$k}};
    }
  }
  return { %short_data };
}

has hivejso_checksum => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_checksum {
  my ( $self ) = @_;
  return $self->calc_checksum(%{$self->hivejso_data});
}

has hivejso_checksum_short => (
  is => 'lazy',
  init_arg => undef,
);

sub _build_hivejso_checksum_short {
  my ( $self ) = @_;
  return $self->calc_checksum(%{$self->hivejso_data_short});
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

sub _parse_first {
  my ( $class, $string, $current ) = @_;
  my $start = defined $current
    ? index($string,'{',$current)
    : index($string,'{');
  return if $start == -1;
  my $end = index($string,'}',$start);
  return if $end == -1;
  my $test = substr($string,$start,$end-$start+1);
  my $another_start = index($test,'{',1);
  if ($another_start == -1) {
    my @result = (
      $start == 0 ? "" : substr($string,0,$start),
      substr($string,$start,$end-$start+1),
      substr($string,$end+1),
    );
    return @result;
  } else {
    return if defined $current && $another_start == $current; # TODO
    return $class->_parse_first($string,$another_start);
  }
}

sub _parse {
  my ( $class, $one, $string ) = @_;
  my @results;
  my @parse_first = $class->_parse_first($string);
  if (@parse_first) {
    my ( $pre, $obj, $post ) = @parse_first;
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

sub add {
  my ( $self, %newattr ) = @_;
  my %newobj = (
    %{$self->hivejso_data},
    %newattr,
  );
  return $self->new(
    %newobj,
    $self->has_checksum ? ( checksum => $self->calc_checksum(%newobj) ) : (),
  );
}

sub add_short {
  my ( $self, %newattr ) = @_;
  my %newobj = (
    %{$self->hivejso_data_short},
    %newattr,
  );
  return $self->new(
    %newobj,
    $self->has_checksum ? ( c => $self->calc_checksum(%newobj) ) : (),
  );
}

1;

__END__

=pod

=head1 NAME

HiveJSO - HiveJSO Perl Implementation

=head1 VERSION

version 0.007

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

  my $new_obj = $obj->add(
    timestamp => 1406479539,
    timestamp_timezone => 120,
  );

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
