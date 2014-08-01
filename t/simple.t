#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;
use JSON::MaybeXS;

{
  my $json = '{"unit_id":1234567890,"ok":1}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit_id,1234567890,'Proper Unit ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product_id,'has no product_id');
  ok(!$obj->has_error_code,'has no error_code');
}

{
  my $obj = HiveJSO->new({ unit_id => 1234567890, ok => 1 });

  isa_ok($obj,'HiveJSO','object');
  is($obj->unit_id,1234567890,'Proper Unit ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_product_id,'has no product_id');
  ok(!$obj->has_error_code,'has no error_code');
  is_deeply(decode_json($obj->hivejso_short),{
    ok => 1,
    u => 1234567890,
    c => 30092052,
  },'Short HiveJSO is fine');
  is_deeply(decode_json($obj->hivejso),{
    ok => 1,
    unit_id => 1234567890,
    checksum => 3014000316,
  },'HiveJSO is fine');
}

{
  my $json = '{"unit_id":1234567890}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/more attributes/,'Invalid HiveJSO with just one attribute');
}

{
  my $json = '{"unit_id":1234567890,"unknown_attribute":1}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/not a valid HiveJSO attribute/,'unknown_attribute is invalid HiveJSO attribute');
}

{
  my $json = '{"unit_id":1234567890,"ok":0}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/ok attribute must be set to 1/,'ok attribute must be set to 1');
}

{
  my $json = '{"u":1234567890,"x":0}';

  eval {
    HiveJSO->new_via_json($json);
  };

  like($@,qr/error_code must be positive integer above 0/,'error_code must be positive integer above 0');
}

done_testing;
