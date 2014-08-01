package HiveJSO::Error;
BEGIN {
  $HiveJSO::Error::AUTHORITY = 'cpan:GETTY';
}
# ABSTRACT: HiveJSO Error for malformed objects
$HiveJSO::Error::VERSION = '0.006';
use Moo;

has garbage => (
  is => 'ro',
  required => 1,
);

has error => (
  is => 'ro',
  required => 1,
);

1;

__END__

=pod

=head1 NAME

HiveJSO::Error - HiveJSO Error for malformed objects

=head1 VERSION

version 0.006

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
