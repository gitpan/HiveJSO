
requires 'JSON::MaybeXS', '0';
requires 'Moo', '0';
requires 'Digest::CRC', '0';

on test => sub {
  requires 'Test::More', '0.96';
};

