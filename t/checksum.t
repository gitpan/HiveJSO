#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;

{
  my $json = '{"unit_id":1234567890,"ok":1}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->hivejso_checksum,"3014000316",'Proper generated checksum');
  ok(!$obj->has_checksum,'Object has no checksum');
}

{
  my $json = '{"unit_id":1234567890,"ok":1,"checksum":3014000316}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

{
  my $json = '{"u":1234567890,"ok":1,"c":30092052}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

{
  my $json = '{"u":1234567890,"ok":1,"c":1234}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/invalid HiveJSO checksum/,'Checksum error is coming up');
}

{
  my $json = '{"u":4321,"d":[[1,100],[2,200]],"c":3388202689}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  ok($obj->has_checksum,'Object has checksum');
}

done_testing;
