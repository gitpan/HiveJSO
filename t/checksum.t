#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $json = '{"did":1234567890,"ok":1,"data":[["tsl250",141]]}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->hivejso_checksum,"3744640343",'Proper generated checksum');
  ok($obj->checksum_ok,'Object is valid');
}

{
  my $json = '{"did":1234567890,"ok":1,"data":[["tsl250",141]],"checksum":3744640343}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->hivejso_checksum,"3744640343",'Proper generated checksum');
  ok($obj->checksum_ok,'Object is valid');
}

{
  my $json = '{"did":1234567890,"ok":1,"data":[["tsl250",141]],"checksum":1234}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok(!$obj->checksum_ok,'Object is not valid');
}

done_testing;
