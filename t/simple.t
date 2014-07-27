#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use HiveJSO;
use JSON::MaybeXS;

{
  my $json = '{"did":1234567890,"ok":1}';

  my $obj = HiveJSO->new_via_json($json);

  isa_ok($obj,'HiveJSO','object');
  is($obj->did,1234567890,'Proper Drone ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_device_id,'has no device_id');
  ok(!$obj->has_error_code,'has no error_code');
}

{
  my $obj = HiveJSO->new({ did => 1234567890, ok => 1 });

  isa_ok($obj,'HiveJSO','object');
  is($obj->did,1234567890,'Proper Drone ID');
  ok($obj->has_ok,'Has an ok attribute');
  is($obj->ok,1,'ok value is 1');
  ok(!$obj->has_timestamp,'has no timestamp');
  ok(!$obj->has_device_id,'has no device_id');
  ok(!$obj->has_error_code,'has no error_code');
}

done_testing;

